#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <math.h>

#define MEMORY_SIZE 4096

typedef enum {
    PSH,
    LOD,
    ADD,
    SUB,
    AND,
    ORR,
    POP,
    MOV,
    JMP,
    CMP,
    JIE,
    PUT,
    HLT
} Instruction;

typedef enum {
    R0 = (int) pow( 10, floor( log10(MEMORY_SIZE) ) ), // 1e{n} for : (1e{n} , 1e{n+1})
    R1,
    R2,
    R3,
    R4
} Register;



int memory[MEMORY_SIZE];
int pc = 0; //program counter, list of instructions or basically the code
int sp = MEMORY_SIZE - 1; //stack pointer, the "RAM" where the calculations take place
bool flag = false;

int map_token(char* s) {
    //instructions
    if (strcmp(s, "PSH") == 0) return PSH;
    if (strcmp(s, "LOD") == 0) return LOD;
    if (strcmp(s, "ADD") == 0) return ADD;
    if (strcmp(s, "SUB") == 0) return SUB;
    if (strcmp(s, "AND") == 0) return AND;
    if (strcmp(s, "ORR") == 0) return ORR;
    if (strcmp(s, "POP") == 0) return POP;
    if (strcmp(s, "MOV") == 0) return MOV;
    if (strcmp(s, "JMP") == 0) return JMP;
    if (strcmp(s, "CMP") == 0) return CMP;
    if (strcmp(s, "JIE") == 0) return JIE;
    if (strcmp(s, "PUT") == 0) return PUT;
    if (strcmp(s, "HLT") == 0) return HLT;

    //registers
    if (strcmp(s, "R0") == 0) return R0;
    if (strcmp(s, "R1") == 0) return R1;
    if (strcmp(s, "R2") == 0) return R2;
    if (strcmp(s, "R3") == 0) return R3;
    if (strcmp(s, "R4") == 0) return R4;

    return atoi(s);
}

void eval(int instr) {
    switch(instr) {
        case PSH: {
                      int val = memory[pc++];
                      memory[sp--] = val;
                      break;
                  }
        case LOD: {
                      int reg_addr = memory[pc++];
                      memory[sp--] = memory[reg_addr];
                      break;
                  }
        case ADD: {
                      int A = memory[++sp]; //pop
                      int B = memory[++sp]; //pop
                      memory[sp--] = A+B;
                      break;
                  }
        case SUB: {
                      int A = memory[++sp]; //pop
                      int B = memory[++sp]; //pop
                      memory[sp--] = B-A;
                      break;
                  }
        case AND: {
                      int A = memory[++sp]; //pop
                      int B = memory[++sp]; //pop
                      memory[sp--] = A&&B;
                      break;
                  }
        case ORR: {
                      int A = memory[++sp]; //pop
                      int B = memory[++sp]; //pop
                      memory[sp--] = A||B;
                      break;
                  }
        case POP: {
                      printf("%d\n",memory[++sp]);
                      break;
                  }
        case MOV: {
                      int R = memory[pc++];
                      int val = memory[pc++];
                      memory[R] = val;
                      break;
                  }
        case JMP: {
                      int target = memory[pc++];
                      pc = target;
                      break;
                  }
        case CMP: {
                      int A = memory[pc++];
                      int B = memory[pc++];
                      flag = memory[A]==memory[B];
                      break;
                  }
        case PUT: {
                      int addr = memory[pc++];
                      int val = memory[sp+1];
                      memory[addr] = val;
                      break;
                  }
        case JIE: {
                      int target = memory[pc++];
                      if (flag)
                          pc = target;
                      break;
                  }
    }
}

int main(int argc, char* argv[]) {
    if (argc < 2) return 1;

    FILE* fptr = fopen(argv[1], "r");
    if (!fptr) return 1;

    char line[32];
    int count = 0;

    while (fgets(line, sizeof(line), fptr) != NULL) {
        line[strcspn(line, "\n")] = 0;
        memory[count++] = map_token(line);
    }
    fclose(fptr);

    while (pc < count && memory[pc] != HLT) {
        eval(memory[pc++]);
    }
    return 0;
}
