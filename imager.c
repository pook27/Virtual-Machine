#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#define SECTOR_SIZE 512
#define REG_BASE    0x007FFF00

// We must mirror the exact CPU instruction set here!
typedef enum {
    PSH, LOD, ADD, SUB, AND, ORR, POP, DRP, MOV, JMP, CMP, JIE, PUT, SYS,
    MUL, DIV, MOD, SHL, SHR, XOR, NOT, JGT, JLT, RUN, RET, LDI, STI, ENT, LEV, 
    LDB, STB, IRET, 
    HLT
} Instruction;

typedef enum {
    R0 = REG_BASE, R1 = REG_BASE + 4, R2 = REG_BASE + 8, R3 = REG_BASE + 12, R4 = REG_BASE + 16,
    RS = REG_BASE + 20, RC = REG_BASE + 24, RY = REG_BASE + 28, RX = REG_BASE + 32, FP = REG_BASE + 36
} Register;

typedef enum {
    CHAR = 1, CLEAR, DRAW, SLEEP, STRING, INPUT, RENDER,
    DISK_READ, DISK_WRITE,
    EXIT = 99
} Syscall;

// The Translation Dictionary
int map_token(char* s) {
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

    if (strcmp(s, "JMP") == 0) return JMP;
    if (strcmp(s, "JIE") == 0) return JIE;
    if (strcmp(s, "JGT") == 0) return JGT;
    if (strcmp(s, "JLT") == 0) return JLT;
    if (strcmp(s, "RUN") == 0) return RUN;
    if (strcmp(s, "RET") == 0) return RET;
    if (strcmp(s, "IRET") == 0) return IRET;

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

    if (strcmp(s, "CHAR") == 0) return CHAR;
    if (strcmp(s, "CLEAR") == 0) return CLEAR;
    if (strcmp(s, "DRAW") == 0) return DRAW;
    if (strcmp(s, "SLEEP") == 0) return SLEEP;
    if (strcmp(s, "STRING") == 0) return STRING;
    if (strcmp(s, "INPUT") == 0) return INPUT;
    if (strcmp(s, "RENDER") == 0) return RENDER;
    if (strcmp(s, "DISK_READ") == 0) return DISK_READ;
    if (strcmp(s, "DISK_WRITE") == 0) return DISK_WRITE;
    if (strcmp(s, "EXIT") == 0) return EXIT;

    return atoi(s);
}

void write32_to_file(FILE* f, int val) {
    uint8_t bytes[4];
    bytes[0] = val & 0xFF;
    bytes[1] = (val >> 8) & 0xFF;
    bytes[2] = (val >> 16) & 0xFF;
    bytes[3] = (val >> 24) & 0xFF;
    fwrite(bytes, 1, 4, f);
}

int main(int argc, char* argv[]) {
    if (argc < 3) {
        printf("Usage: %s <output.img> <file1.vm> [file2.vm ...]\n", argv[0]);
        return 1;
    }

    FILE* img = fopen(argv[1], "wb");
    if (!img) return 1;

    for (int i = 2; i < argc; i++) {
        FILE* vm = fopen(argv[i], "r");
        if (!vm) {
            printf("Could not open %s\n", argv[i]);
            continue;
        }

        printf("Writing %s to image...\n", argv[i]);
        char line[32];
        int bytes_written = 0;

        while (fgets(line, sizeof(line), vm)) {
            line[strcspn(line, "\n")] = 0; // Strip the newline
            int val = map_token(line);     // Actually parse the token!
            write32_to_file(img, val);
            bytes_written += 4;
        }
        fclose(vm);

        int padding = SECTOR_SIZE - (bytes_written % SECTOR_SIZE);
        if (padding != SECTOR_SIZE) {
            for (int p = 0; p < padding; p++) fputc(0, img);
        }
    }

    long current_size = ftell(img);
    long target_size = 1024 * 1024; // 1 MB
    while (current_size < target_size) {
        fputc(0, img);
        current_size++;
    }

    fclose(img);
    printf("Successfully built Hard Drive: %s\n", argv[1]);
    return 0;
}
