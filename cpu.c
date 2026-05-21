#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <unistd.h>
#include <raylib.h>
#include "vm.h"

uint8_t memory[MEMORY_SIZE];
int pc = 0;
int sp = REG_BASE - 4;
int flag = 0;
FILE* disk = NULL;

bool headless = false;
bool debug = false;

Texture2D display_texture;
Color pixel_buffer[VRAM_SIZE];
Color palette[256];

void init_palette() {
    for (int i = 0; i < 256; i++) {
        uint8_t r = ((i >> 5) & 7) * 255 / 7;
        uint8_t g = ((i >> 2) & 7) * 255 / 7;
        uint8_t b = (i & 3) * 255 / 3;
        palette[i] = (Color){r, g, b, 255};
    }
}

void init_display() {
    SetTraceLogLevel(LOG_WARNING);
    init_palette();

    SetExitKey(0);

    InitWindow(VRAM_WIDTH * 3, VRAM_HEIGHT * 3, "Virtual Machine OS - VGA Graphics");
    SetTargetFPS(60); 

    Image img = GenImageColor(VRAM_WIDTH, VRAM_HEIGHT, BLACK);
    display_texture = LoadTextureFromImage(img);
    UnloadImage(img);
}

void check_memory(int addr) {
    if (addr < 0 || addr >= MEMORY_SIZE) {
        printf("\n========================================\n");
        printf("[FATAL VM CRASH] Memory Access Violation!\n");
        printf("Attempted to access address: %d\n", addr);
        printf("Current PC: %d | Current SP: %d\n", pc, sp);
        printf("========================================\n\n");
        exit(1);
    }
}

void write32(int addr, int val) {
    check_memory(addr); check_memory(addr + 3);
    memory[addr] = val & 0xFF; memory[addr+1] = (val >> 8) & 0xFF;
    memory[addr+2] = (val >> 16) & 0xFF; memory[addr+3] = (val >> 24) & 0xFF;
}

int read32(int addr) {
    check_memory(addr); check_memory(addr + 3);
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
    int val = read32(pc);
    pc += 4;
    return val;
}

void push(int val) {
    sp -= 4;
    write32(sp, val);
}

int pop() {
    int val = read32(sp);
    sp += 4;
    return val;
}

void eval(int instr) {
    switch(instr) {
        case PSH: push(fetch()); break;
        case LOD: push(read32(fetch())); break;
        case PUT: write32(fetch(), read32(sp)); break;
        case POP: {
                      int val = pop();
                      if (headless) printf("%d\n", val); 
                      break;
                  }
        case DRP: pop(); break;
        case LDB: push(read8(read32(fetch()))); break;
        case STB: write8(read32(fetch()), read32(sp) & 0xFF); break;

        case ADD: { int a = pop(); int b = pop(); push(b + a); break; }
        case SUB: { int a = pop(); int b = pop(); push(b - a); break; }
        case MUL: { int a = pop(); int b = pop(); push(b * a); break; }
        case DIV: { 
                      int a = pop(); int b = pop();
                      if (debug) {
                          if(a == 0) { printf("[FATAL VM CRASH] Division by Zero at PC: %d\n", pc); exit(1); }
                      }
                      push(b / a); break; 
                  }
        case MOD: { 
                      int a = pop(); int b = pop(); 
                      if (debug) {
                          if(a == 0) { printf("[FATAL VM CRASH] Modulo by Zero at PC: %d\n", pc); exit(1); } 
                      }
                      push(b % a); break; 
                  }
        case AND: { int a = pop(); int b = pop(); push(b & a); break; }
        case ORR: { int a = pop(); int b = pop(); push(b | a); break; }
        case XOR: { int a = pop(); int b = pop(); push(b ^ a); break; }
        case SHL: { int a = pop(); int b = pop(); push(b << a); break; }
        case SHR: { int a = pop(); int b = pop(); push(b >> a); break; }
        case NOT: push(~pop()); break;

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

        case RUN: { int target = fetch(); push(pc); pc = target; break; }
        case RET: pc = pop(); break;
        case RTI: pc = pop(); break;
        case ENT: push(read32(FP)); write32(FP, sp); break;
        case LEV: sp = read32(FP); write32(FP, pop()); break;

        case SYS: {
                      int sys_id = read32(RS);
                      if (debug) {
                          printf("\n[SYSCALL] Triggered SYS ID: %d at PC: %d\n", sys_id, pc-4);
                      }
                      switch(sys_id) {
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
                                      pixel_buffer[i] = palette[read8(VRAM_BASE + i)];
                                  }
                                  UpdateTexture(display_texture, pixel_buffer);
                                  BeginDrawing();
                                  ClearBackground(BLACK);
                                  DrawTextureEx(display_texture, (Vector2){0,0}, 0.0f, 3.0f, WHITE);
                                  EndDrawing();

                                  // --- VSYNC HARDWARE HOOK ---
                                  if (WindowShouldClose()) exit(0);
                                  for (int k = 1; k < 350; k++) {
                                      write8(KEYBOARD_BASE + k, IsKeyDown(k) ? 1 : 0);
                                  }
                              }
                              break;
                          case DISK_READ: {
                                              FILE* disk = fopen("drive.img", "rb");
                                              if (disk) {
                                                  int sectors = read32(RC);
                                                  if (sectors <= 0) sectors = 1; 
                                                  fseek(disk, read32(RX) * 512, SEEK_SET);
                                                  (void)fread(&memory[read32(RY)], 1, 512 * sectors, disk);
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
                          case EXIT: 
                                           if (debug) {
                                               printf("\n[VM SHUTDOWN] Program requested EXIT via Syscall 99.\n");
                                               printf("Final PC: %d | Final SP: %d\n", pc, sp);
                                           }
                                           exit(0);
                                           break;
                          default:
                                           if (debug) {
                                               if (headless) printf("Error: Unknown syscall %d\n", read32(RS));
                                           }
                                           break;
                      }
                      break;
                  }
    }
}

int main(int argc, char* argv[]) {
    char* test_file = NULL;

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--headless") == 0) headless = true;
        else if (strcmp(argv[i], "--debug") == 0) debug = true;
        else test_file = argv[i];
    }

    if (test_file) {
        FILE* test_bin = fopen(test_file, "rb"); 
        if (test_bin) {
            fseek(test_bin, 0, SEEK_END);
            long sz = ftell(test_bin);
            rewind(test_bin);
            (void)fread(memory, 1, sz, test_bin);
            fclose(test_bin);
        } else {
            printf("Error: Could not open %s\n", test_file);
            return 1;
        }
    } else {
        FILE* disk_f = fopen("drive.img", "rb");
        if (!disk_f) {
            printf("BIOS FATAL ERROR: No bootable drive.img found\n");
            return 1;
        }
        long bytes = fread(memory, 1, 512 * 20, disk_f);
        fclose(disk_f);

        // Diagnostic to prove bootloader landed at address
        if (debug) {
            printf("[BIOS] Read %ld bytes. memory[0..3] = %02X %02X %02X %02X\n",
                    bytes, memory[0], memory[1], memory[2], memory[3]);
        }
    }

    if (!headless) init_display();

    pc = 0;
    sp = REG_BASE - 4;

    if (debug) printf("\n[VM BOOTING] PC: %d | SP: %d | RAM: %d bytes\n", pc, sp, MEMORY_SIZE);

    int trace_count = 0;
    while (pc < MEMORY_SIZE && read32(pc) != HLT) {

        // Print the first 50 instructions so we don't flood the terminal
        if (debug) {
            if (trace_count < 50) {
                printf("[TRACE] PC: %-5d | SP: %-8d | Opcode: %d\n", pc, sp, read32(pc));
                trace_count++;
            } else if (trace_count == 50) {
                printf("[TRACE] ... Trace paused to prevent terminal flood ...\n");
                trace_count++;
            }
        }
        eval(fetch());
    }

    // If the loop breaks naturally, why did it break?
    if (pc >= MEMORY_SIZE) {
        printf("\n========================================\n");
        printf("[FATAL] Program Counter went out of bounds (PC: %d)\n", pc);
        printf("========================================\n\n");
    } else if (debug) {
        printf("\n========================================\n");
        if (read32(pc) == HLT) printf("[VM HALTED] Reached HLT instruction at PC: %d\n", pc);
        else printf("[VM HALTED] Unknown reason at PC: %d\n", pc);
        printf("========================================\n\n");
    }

    if (!headless) CloseWindow();
    return 0;
}
