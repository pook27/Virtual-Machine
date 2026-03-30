#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <math.h>
#include <unistd.h>

#define MEMORY_SIZE 4096

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
    CAL,
    RET,
    HLT
} Instruction;

typedef enum {
    R0 = (int) pow( 10, floor( log10(MEMORY_SIZE) ) ), // 1e{n} for : (1e{n} , 1e{n+1})
    R1,                                                // general purpose Register
    R2,                                                // general purpose Register
    R3,                                                // general purpose Register
    R4,                                                // general purpose Register
    RS,                                                // system calls register
    RC,                                                // character register
    RY,                                                // Y register
    RX                                                 // X register
} Register;

typedef enum {
   CHAR = 1,
   CLEAR,
   DRAW,
   SLEEP,
   STRING,
   EXIT = 99
} Syscall;

int memory[MEMORY_SIZE];
int pc = 0; //program counter, list of instructions or basically the code
int sp = MEMORY_SIZE - 1; //stack pointer, the "RAM" where the calculations take place
int flag = 0;

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
    if (strcmp(s, "CAL") == 0) return CAL;
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

    //syscalls
    //
    if (strcmp(s, "CHAR") == 0) return CHAR;
    if (strcmp(s, "CLEAR") == 0) return CLEAR;
    if (strcmp(s, "DRAW") == 0) return DRAW;
    if (strcmp(s, "SLEEP") == 0) return SLEEP;
    if (strcmp(s, "STRING") == 0) return STRING;
    if (strcmp(s, "EXIT") == 0) return EXIT;


    return atoi(s);
}

void eval(int instr) {
    switch(instr) {
        case PSH: {
                      if (sp <= RX) {
                          printf("Stack Overflow\n");
                          exit(1);
                      }
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
        case DRP: {
                      sp++;
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
        case PUT: {
                      int addr = memory[pc++];
                      int val = memory[sp+1];
                      memory[addr] = val;
                      break;
                  }
        case MUL: {
                      int A = memory[++sp]; 
                      int B = memory[++sp]; 
                      memory[sp--] = B * A;
                      break;
                  }
        case DIV: {
                      int A = memory[++sp]; 
                      int B = memory[++sp]; 
                      if (A == 0) { printf("Error: Division by zero\n"); exit(1); }
                      memory[sp--] = B / A;
                      break;
                  }
        case MOD: {
                      int A = memory[++sp]; 
                      int B = memory[++sp]; 
                      if (A == 0) { printf("Error: Modulo by zero\n"); exit(1); }
                      memory[sp--] = B % A;
                      break;
                  }
        case SHL: {
                      int A = memory[++sp]; 
                      int B = memory[++sp]; 
                      memory[sp--] = B << A;
                      break;
                  }
        case SHR: {
                      int A = memory[++sp]; 
                      int B = memory[++sp]; 
                      memory[sp--] = B >> A;
                      break;
                  }
        case XOR: {
                      int A = memory[++sp]; 
                      int B = memory[++sp]; 
                      memory[sp--] = B ^ A;
                      break;
                  }
        case NOT: {
                      int A = memory[++sp]; 
                      memory[sp--] = ~A;
                      break;
                  }        
        case CMP: {
                      int A = memory[pc++];
                      int B = memory[pc++];
                      if (memory[A] == memory[B]) flag = 0;
                      else if (memory[A] > memory[B]) flag = 1;
                      else flag = -1;
                      break;
                  }
        case JIE: {
                      int target = memory[pc++];
                      if (flag == 0) pc = target;
                      break;
                  }
        case JGT: {
                      int target = memory[pc++];
                      if (flag == 1) pc = target;
                      break;
                  }
        case JLT: {
                      int target = memory[pc++];
                      if (flag == -1) pc = target;
                      break;
                  }
        case CAL: {
                       int target = memory[pc++];
                       if (sp <= RX) {
                            printf("Stack Overflow during CAL.\n");
                            exit(1);
                       }
                       memory[sp--] = pc;
                       pc = target;
                       break;
                   }
        case RET: {
                      if (sp >= MEMORY_SIZE - 1) {
                          printf("Error: Stack underflow on RET\n");
                          exit(1);
                      }
                      pc = memory[++sp];
                      break;
                  }
        case SYS: {
                      switch(memory[RS]) {
                          case CHAR: //print character
                              printf("%c", memory[RC]);
                              fflush(stdout);
                              break;
                          case CLEAR: //clear screen
                              printf("\033[2J\033[H");
                              fflush(stdout);
                              break;
                          case DRAW: //draw pixel
                              printf("\033[%d;%dH█", memory[RY], memory[RX]);
                              fflush(stdout);
                              break;
                          case SLEEP: //sleep
                              usleep(1000);
                              break;
                          case STRING: //print string
                              int addr = memory[RC];
                              while (memory[addr] != 0) {
                                printf("%c", memory[addr]);
                                addr++;
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

    bool debug_mode = false;
    if (argc >= 3 && strcmp(argv[2], "--debug") == 0) {
        debug_mode = true;
        printf("--- DEBUG MODE ENABLED ---\n");
    }

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
        if (debug_mode) {
            printf("\n[PC: %04d] | Instruction Code: %d\n", pc, memory[pc]);
            // Print your registers and stack pointer. Adjust variable names to match yours!
            printf("Registers -> RX: %d | RY: %d | RS: %d\n", memory[RX], memory[RY], memory[RS]);
            printf("Stack Ptr -> %d\n", sp);
            printf("Press ENTER to step...");
            getchar();
        }
    }
    return 0;
}
