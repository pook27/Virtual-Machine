#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <unistd.h>
#include <termios.h>
#include <signal.h>
#include <stdint.h>

#define MEMORY_SIZE (8 * 1024 * 1024) // * MB OF RAM!!!!
#define REG_BASE    0x007FFF00        // Registers live here
#define VRAM_BASE   0x00100000        // VRAM starts exactly at index 4096
#define VRAM_WIDTH  64                // 64 columns
#define VRAM_HEIGHT 32                // 32 rows
#define VRAM_SIZE   (VRAM_WIDTH * VRAM_HEIGHT) // 2048 integers of VRAM
#define CLOCK_HZ 100000               // 100 kHz CPU

typedef enum {
    PSH,
    LOD,
    ADD,
    SUB,
    AND,
    ORR,
    POP,
    DRP,
    MOV,
    JMP,
    CMP,
    JIE,
    PUT,
    SYS,
    MUL,
    DIV,
    MOD,
    SHL,
    SHR,
    XOR,
    NOT,
    JGT,
    JLT,
    RUN,
    RET,
    LDI,
    STI,
    ENT,
    LEV,
    LDB,
    STB,
    HLT
} Instruction;

typedef enum {
    R0 = REG_BASE,                                                    // general purpose Register
    R1 = REG_BASE + 4,                                                // general purpose Register
    R2 = REG_BASE + 8,                                                // general purpose Register
    R3 = REG_BASE + 12,                                               // general purpose Register
    R4 = REG_BASE + 16,                                               // general purpose Register
    RS = REG_BASE + 20,                                               // system calls registet
    RC = REG_BASE + 24,                                               // character register
    RY = REG_BASE + 28,                                               // Y register
    RX = REG_BASE + 32,                                               // X register
    FP = REG_BASE + 36                                                // Frame Pointer
} Register;

typedef enum {
    CHAR = 1,
    CLEAR,
    DRAW,
    SLEEP,
    STRING,
    INPUT,
    RENDER,
    EXIT = 99
} Syscall;

uint8_t memory[MEMORY_SIZE];
int pc = 0; //program counter, list of instructions or basically the code
int sp = REG_BASE - 4; //stack pointer, the "RAM" where the calculations take place
int flag = 0;

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

struct termios original_termios;

void restore_terminal() {
    tcsetattr(STDIN_FILENO, TCSANOW, &original_termios);
    printf("\033[?25h\033[0m\033[?1049l"); 
    fflush(stdout);
}

void handle_sigint(int sig) {
    (void)sig; 
    printf("\n[VM] Halted by user (Ctrl+C).\n");
    exit(0); 
}

void init_terminal() {
    tcgetattr(STDIN_FILENO, &original_termios);
    atexit(restore_terminal);
    signal(SIGINT, handle_sigint);
    printf("\033[?1049h\033[?25l");
    fflush(stdout);
    struct termios raw = original_termios;
    raw.c_lflag &= ~(ICANON | ECHO);
    raw.c_cc[VMIN] = 0;
    raw.c_cc[VTIME] = 0;
    tcsetattr(STDIN_FILENO, TCSANOW, &raw);
}

int map_token(char* s) {

    //instructions
    //
    if (strcmp(s, "PSH") == 0) return PSH;
    if (strcmp(s, "LOD") == 0) return LOD;    
    if (strcmp(s, "POP") == 0) return POP;
    if (strcmp(s, "DRP") == 0) return DRP;
    if (strcmp(s, "MOV") == 0) return MOV;
    if (strcmp(s, "CMP") == 0) return CMP;
    if (strcmp(s, "PUT") == 0) return PUT;
    if (strcmp(s, "SYS") == 0) return SYS;
    if (strcmp(s, "HLT") == 0) return HLT;
    if (strcmp(s, "LDI") == 0) return LDI;
    if (strcmp(s, "STI") == 0) return STI;
    if (strcmp(s, "ENT") == 0) return ENT;
    if (strcmp(s, "LEV") == 0) return LEV;
    if (strcmp(s, "LDB") == 0) return LDB;
    if (strcmp(s, "STB") == 0) return STB;

    // operators
    //
    if (strcmp(s, "ADD") == 0) return ADD;
    if (strcmp(s, "SUB") == 0) return SUB;
    if (strcmp(s, "AND") == 0) return AND;
    if (strcmp(s, "ORR") == 0) return ORR;
    if (strcmp(s, "MUL") == 0) return MUL;
    if (strcmp(s, "DIV") == 0) return DIV;
    if (strcmp(s, "MOD") == 0) return MOD;
    if (strcmp(s, "SHL") == 0) return SHL;
    if (strcmp(s, "SHR") == 0) return SHR;
    if (strcmp(s, "XOR") == 0) return XOR;
    if (strcmp(s, "NOT") == 0) return NOT;

    // function and jump flow
    //
    if (strcmp(s, "JMP") == 0) return JMP;
    if (strcmp(s, "JIE") == 0) return JIE;
    if (strcmp(s, "JGT") == 0) return JGT;
    if (strcmp(s, "JLT") == 0) return JLT;
    if (strcmp(s, "RUN") == 0) return RUN;
    if (strcmp(s, "RET") == 0) return RET;

    //registers
    //
    if (strcmp(s, "R0") == 0) return R0;
    if (strcmp(s, "R1") == 0) return R1;
    if (strcmp(s, "R2") == 0) return R2;
    if (strcmp(s, "R3") == 0) return R3;
    if (strcmp(s, "R4") == 0) return R4;
    if (strcmp(s, "RS") == 0) return RS;
    if (strcmp(s, "RC") == 0) return RC;
    if (strcmp(s, "RY") == 0) return RY;
    if (strcmp(s, "RX") == 0) return RX;
    if (strcmp(s, "FP") == 0) return FP;

    //syscalls
    //
    if (strcmp(s, "CHAR") == 0) return CHAR;
    if (strcmp(s, "CLEAR") == 0) return CLEAR;
    if (strcmp(s, "DRAW") == 0) return DRAW;
    if (strcmp(s, "SLEEP") == 0) return SLEEP;
    if (strcmp(s, "STRING") == 0) return STRING;
    if (strcmp(s, "INPUT") == 0) return INPUT;
    if (strcmp(s, "RENDER") == 0) return RENDER;
    if (strcmp(s, "EXIT") == 0) return EXIT;


    return atoi(s);
}

void eval(int instr) {
    switch(instr) {
        // GENERAL
        case PSH: push(fetch()); break;
        case LOD: push(read32(fetch())); break;
        case PUT: write32(fetch(), read32(sp)); break;
        case POP: printf("%d\n", pop()); break;
        case DRP: pop(); break;
        case LDB: push(read8(read32(fetch()))); break;
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
        case ENT: push(read32(FP)); write32(FP, sp); break;
        case LEV: sp = read32(FP); write32(FP, pop()); break;
        case SYS: {
                      switch(read32(RS)) {
                          case CHAR: //print character
                              printf("%c", read32(RC));
                              fflush(stdout);
                              break;
                          case CLEAR: //clear screen
                              printf("\033[2J\033[H");
                              for(int i = 0; i < VRAM_SIZE; i++) write8(VRAM_BASE + i, 0);
                              fflush(stdout);
                              break;
                          case DRAW: //draw pixel
                              printf("\033[%d;%dH█", read32(RY), read32(RX));
                              fflush(stdout);
                              break;
                          case SLEEP: //sleep
                              usleep(read32(RX)*1000);
                              break;
                          case STRING: //print string
                              int addr = read32(RC);
                              while (read32(addr) != 0) {
                                  printf("%c", read32(addr));
                                  addr += 4;
                              }
                              fflush(stdout);
                              break;
                          case INPUT: //input from user
                              char ch;
                              int n = read(STDIN_FILENO, &ch, 1);
                              if (n == 1) write32(RC, ch);
                              break;
                          case RENDER: // render to terminal
                              printf("\033[H"); // Reset cursor to top-left
                              for (int y = 0; y < VRAM_HEIGHT; y++) {
                                  for (int x = 0; x < VRAM_WIDTH; x++) {
                                      int pixel_color = read8(VRAM_BASE + (y * VRAM_WIDTH) + x);
                                      if (pixel_color != 0) printf("\033[%dm█\033[0m", pixel_color);
                                      else printf(" ");
                                  }
                                  printf("\n");
                              }
                              fflush(stdout);
                              break;
                          case EXIT: //exit syscall
                              printf("Program Exited via Syscall.\n");
                              exit(0);
                              break;
                          default:
                              printf("Error: Unkown syscall %d\n", memory[RS]);
                              break;
                      }
                      break;
                  }
    }
}

int main(int argc, char* argv[]) {
    if (argc < 2){
        printf("Usage: %s <program.asm> [--debug]\n", argv[0]);
        return 1;
    }

    FILE* fptr = fopen(argv[1], "r");
    if (!fptr) return 1;

    char line[32];
    
    int addr = 0;
    while (fgets(line, sizeof(line), fptr) != NULL) {
        line[strcspn(line, "\n")] = 0;
        write32(addr, map_token(line));
        addr += 4;
    }
    fclose(fptr);
    int count = addr;

    if (isatty(STDOUT_FILENO))
        init_terminal();

    int cycles_per_ms = CLOCK_HZ / 1000;
    int cycle_count = 0;

    while (pc < count && read32(pc) != HLT) {
        eval(fetch());

        cycle_count++;
        if (cycle_count >= cycles_per_ms) {
            usleep(1000); 
            cycle_count = 0;
        }
    }
    return 0;
}
