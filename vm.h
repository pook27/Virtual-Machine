#ifndef VM_H
#define VM_H

// --- HARDWARE ARCHITECTURE ---
#define MEMORY_SIZE   (8 * 1024 * 1024) 
#define REG_BASE      0x007FFF00
#define KEYBOARD_BASE 0x00200000
#define VRAM_BASE     0x00100000
#define VRAM_WIDTH    64
#define VRAM_HEIGHT   32
#define VRAM_SIZE     (VRAM_WIDTH * VRAM_HEIGHT)
#define SECTOR_SIZE   512
#define CLOCK_HZ      100000

// --- INSTRUCTION SET ---
typedef enum {
    PSH, LOD, ADD, SUB, AND, ORR, POP, DRP, MOV, JMP, CMP, JIE, PUT, SYS,
    MUL, DIV, MOD, SHL, SHR, XOR, NOT, JGT, JLT, RUN, RET, LDI, STI, ENT, LEV, 
    LDB, STB, RTI, 
    HLT // Always keep HLT last!
} Instruction;

// --- REGISTERS ---
typedef enum {
    R0 = REG_BASE, R1 = REG_BASE + 4, R2 = REG_BASE + 8, R3 = REG_BASE + 12, R4 = REG_BASE + 16,
    RS = REG_BASE + 20, RC = REG_BASE + 24, RY = REG_BASE + 28, RX = REG_BASE + 32, FP = REG_BASE + 36
} Register;

// --- SYSCALLS ---
typedef enum {
    CHAR = 1, CLEAR, DRAW, SLEEP, STRING, INPUT, RENDER,
    DISK_READ, DISK_WRITE, DRAW_TEXT,
    EXIT = 99
} Syscall;

#endif
