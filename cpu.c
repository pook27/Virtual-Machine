#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <unistd.h>
#include <stdbool.h>
#include <stdint.h>
#include <raylib.h>

#include "vm.h"

uint8_t memory[MEMORY_SIZE];
int pc = 0; //program counter, list of instructions or basically the code
int sp = REG_BASE - 4; //stack pointer, the "RAM" where the calculations take place
int flag = 0; //for jumping conditionals and comaprisons
bool headless = false;

Texture2D display_texture;
Color pixel_buffer[VRAM_SIZE];

void init_display() {
    SetTraceLogLevel(LOG_WARNING);
    InitWindow(VRAM_WIDTH * 10, VRAM_HEIGHT * 10, "Virtual Machine OS");
    SetTargetFPS(60); 

    Image img = GenImageColor(VRAM_WIDTH, VRAM_HEIGHT, BLACK);
    display_texture = LoadTextureFromImage(img);
    UnloadImage(img);
}

Color get_raylib_color(uint8_t color_code) {
    switch(color_code) {
        case 31: return RED;
        case 32: return GREEN;
        case 33: return YELLOW;
        case 34: return BLUE;
        case 35: return MAGENTA;
        case 36: return (Color){0, 255, 255, 255};
        case 37: return WHITE;
        default: return BLACK;
    }
}

void check_memory(int addr) {
    if (addr < 0 || addr >= MEMORY_SIZE) {
        printf("\n[FATAL VM ERROR] Memory access violation at address: %d\n", addr);
        exit(1);
    }
}

void write32(int addr, int val) {
    check_memory(addr);
    check_memory(addr + 3);
    memory[addr] = val & 0xFF;
    memory[addr+1] = (val >> 8) & 0xFF;
    memory[addr+2] = (val >> 16) & 0xFF;
    memory[addr+3] = (val >> 24) & 0xFF;
}

int read32(int addr) {
    check_memory(addr);
    check_memory(addr + 3);
    return memory[addr] | (memory[addr+1] << 8) | (memory[addr+2] << 16) | (memory[addr+3] << 24);
}

void write8(int addr, uint8_t val) {
    check_memory(addr);
    memory[addr] = val;
}

uint8_t read8(int addr) {
    check_memory(addr);
    return memory[addr];
}

int fetch() {
    int val = read32(pc); // Read 4 bytes at the Program Counter
    pc += 4;              // Advance PC by 4 bytes
    return val;
}

void push(int val) {
    sp -= 4;              // Move stack pointer up by 4 bytes
    write32(sp, val);     // Write the 32-bit integer
}

int pop() {
    int val = read32(sp); // Read the 32-bit integer at the stack pointer
    sp += 4;              // Move stack pointer down by 4 bytes
    return val;
}

void eval(int instr) {
    switch(instr) {
        // GENERAL
        case PSH: push(fetch()); break;
        case LOD: push(read32(fetch())); break;
        case PUT: write32(fetch(), read32(sp)); break;
        case POP: {
            int val = pop();
            if (headless) printf("%d\n", val);
            break;
        }
        case DRP: pop(); break;
        case LDB: push(read8(fetch())); break;
        case STB: write8(read32(fetch()), read32(sp) & 0xFF); break;

                  // MATH & LOGIC
        case ADD: { int a = pop(); int b = pop(); push(b + a); break; }
        case SUB: { int a = pop(); int b = pop(); push(b - a); break; }
        case MUL: { int a = pop(); int b = pop(); push(b * a); break; }
        case DIV: { int a = pop(); int b = pop(); if(a==0)exit(1); push(b / a); break; }
        case MOD: { int a = pop(); int b = pop(); if(a==0)exit(1); push(b % a); break; }
        case AND: { int a = pop(); int b = pop(); push(b & a); break; }
        case ORR: { int a = pop(); int b = pop(); push(b | a); break; }
        case XOR: { int a = pop(); int b = pop(); push(b ^ a); break; }
        case SHL: { int a = pop(); int b = pop(); push(b << a); break; }
        case SHR: { int a = pop(); int b = pop(); push(b >> a); break; }
        case NOT: push(~pop()); break;

                  // MEMORY & JUMPS
        case LDI: push(read32(read32(fetch()))); break;
        case STI: write32(read32(fetch()), read32(sp)); break;
        case MOV: { int reg = fetch(); write32(reg, fetch()); break; }
        case JMP: pc = fetch(); break;
        case CMP: { 
                      int a = read32(fetch()); 
                      int b = read32(fetch()); 
                      if (a == b) flag = 0; else if (a > b) flag = 1; else flag = -1; 
                      break; 
                  }
        case JIE: { int target = fetch(); if (flag == 0) pc = target; break; }
        case JGT: { int target = fetch(); if (flag == 1) pc = target; break; }
        case JLT: { int target = fetch(); if (flag == -1) pc = target; break; }

                  // FUNCTIONS
        case RUN: { int target = fetch(); push(pc); pc = target; break; }
        case RET: pc = pop(); break;
        case RTI: pc = pop(); break;
        case ENT: push(read32(FP)); write32(FP, sp); break;
        case LEV: sp = read32(FP); write32(FP, pop()); break;
        case SYS: {
            switch(read32(RS)) {
                case CHAR: 
                    if (headless) { printf("%c", read32(RC)); fflush(stdout); }
                    break;
                case STRING: 
                    if (headless) {
                        int addr = read32(RC);
                        while (read32(addr) != 0) {
                            printf("%c", (char)read32(addr));
                            addr += 4;
                        }
                        fflush(stdout);
                    }
                    break;
                case CLEAR: 
                    if (!headless) {
                        for(int i = 0; i < VRAM_SIZE; i++) write8(VRAM_BASE + i, 0);
                    }
                    break;
                case DRAW:
                    // Legacy terminal escape code deleted. VRAM directly handles graphics now.
                    break;
                case SLEEP: 
                    usleep(read32(RX)*1000);
                    break;
                case INPUT: 
                    if (!headless) {
                        int key = GetCharPressed();
                        if (key > 0) write32(RC, key);
                    }
                    break;
                case RENDER: 
                    if (!headless) {
                        for (int i = 0; i < VRAM_SIZE; i++) {
                            pixel_buffer[i] = get_raylib_color(read8(VRAM_BASE + i));
                        }
                        UpdateTexture(display_texture, pixel_buffer);
                        BeginDrawing();
                        ClearBackground(BLACK);
                        DrawTextureEx(display_texture, (Vector2){0,0}, 0.0f, 10.0f, WHITE);
                        EndDrawing();
                    }
                    break;
                case DISK_READ: {
                    FILE* disk = fopen("drive.img", "rb");
                    if (disk) {
                        fseek(disk, read32(RX) * 512, SEEK_SET);
                        fread(&memory[read32(RY)], 1, 512, disk); 
                        fclose(disk);
                    }
                    break; 
                }
                case DISK_WRITE: {
                    FILE* disk = fopen("drive.img", "r+b");
                    if (disk) {
                        fseek(disk, read32(RX) * 512, SEEK_SET);
                        fwrite(&memory[read32(RY)], 1, 512, disk);
                        fclose(disk);
                    }
                    break; 
                }
                case DRAW_TEXT: {
                    if (!headless) {
                        char text_buffer[256];
                        int addr = read32(RC);
                        int i = 0;
                        while (read32(addr) != 0 && i < 255) {
                            text_buffer[i++] = (char)read32(addr);
                            addr += 4;
                        }
                        text_buffer[i] = '\0';
                        BeginDrawing();
                        DrawText(text_buffer, read32(RX), read32(RY), read32(R1), get_raylib_color(read32(R2)));
                        EndDrawing();
                    }
                    break;
                }
                case EXIT: 
                    if (headless) printf("Program Exited via Syscall.\n");
                    exit(0);
                    break;
                default:
                    if (headless) printf("Error: Unknown syscall %d\n", read32(RS));
                    break;
            }
            break;
        }    
    }
}

int main(int argc, char* argv[]) {
    char* test_file = NULL;

    // Command Line Args parser
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--headless") == 0) {
            headless = true;
        } else {
            test_file = argv[i];
        }
    }

    // BOOT SEQUENCE
    if (test_file) {
        // Direct Binary Load (Unit Tests)
        FILE* test_bin = fopen(test_file, "rb"); // 'rb' for raw binary!
        if (test_bin) {
            fseek(test_bin, 0, SEEK_END);
            long sz = ftell(test_bin);
            rewind(test_bin);
            fread(memory, 1, sz, test_bin);
            fclose(test_bin);
        } else {
            printf("Error: Could not open %s\n", test_file);
            return 1;
        }
    } else {
        // True OS Boot (Drive.img)
        FILE* disk = fopen("drive.img", "rb");
        if (!disk) {
            printf("BIOS FATAL ERROR: No bootable drive.img found\n");
            return 1;
        }
        fread(memory, 1, 512, disk);
        fclose(disk);
    }

    if (!headless) init_display();

    int cycles_per_ms = CLOCK_HZ / 1000;
    int cycle_count = 0;
    int interrupt_clock = 0;

    pc = 0;

    while (pc < MEMORY_SIZE && read32(pc) != HLT) {
        if (!headless && WindowShouldClose()) break;

        eval(fetch());

        cycle_count++;
        if (cycle_count >= cycles_per_ms) {
            usleep(1000); 
            cycle_count = 0;
            interrupt_clock++;

            if (!headless) {
                write8(KEYBOARD_BASE, IsKeyDown(KEY_W) ? 1 : 0);
                write8(KEYBOARD_BASE + 1, IsKeyDown(KEY_S) ? 1 : 0);
            }

            if (interrupt_clock >= 16) {
                interrupt_clock = 0;
                int isr_address = read32(4); 
                if (isr_address != 0) {
                    push(pc);
                    pc = isr_address;
                }
            }
        }
    }
    
    if (!headless) CloseWindow();
    return 0;
}
