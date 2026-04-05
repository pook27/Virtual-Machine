#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "vm.h" // The new master header!

#define MAX_TOKENS 8192
#define MAX_TOKENS_LEN 32
#define MAX_LABELS 256
#define MAX_LINE_LEN 256
#define MAX_MACROS 256

typedef struct { char name[MAX_TOKENS_LEN]; int address; int is_data; } Label;
typedef struct { char name[MAX_TOKENS_LEN]; char value[MAX_TOKENS_LEN]; } Macro;

char data_tokens[MAX_TOKENS][MAX_TOKENS_LEN];
int data_token_count = 0;
char text_tokens[MAX_TOKENS][MAX_TOKENS_LEN];
int text_token_count = 0;

int current_section = 0; // 0 for .TEXT, 1 for .DATA
int base_address = 0;    // NEW: Handles the offset for the OS Kernel!

Label labels[MAX_LABELS]; int label_count = 0;
Macro macros[MAX_MACROS]; int macro_count = 0;

void strip_comments(char *line) {
    char *comment_pos = strchr(line, ';');
    if (comment_pos != NULL) *comment_pos = '\0';
}

int map_token(char* s) {
    if (strcmp(s, "PSH") == 0) return PSH;
    if (strcmp(s, "LOD") == 0) return LOD;
    if (strcmp(s, "ADD") == 0) return ADD;
    if (strcmp(s, "SUB") == 0) return SUB;
    if (strcmp(s, "AND") == 0) return AND;
    if (strcmp(s, "ORR") == 0) return ORR;
    if (strcmp(s, "POP") == 0) return POP;
    if (strcmp(s, "DRP") == 0) return DRP;
    if (strcmp(s, "MOV") == 0) return MOV;
    if (strcmp(s, "JMP") == 0) return JMP;
    if (strcmp(s, "CMP") == 0) return CMP;
    if (strcmp(s, "JIE") == 0) return JIE;
    if (strcmp(s, "PUT") == 0) return PUT;
    if (strcmp(s, "SYS") == 0) return SYS;
    if (strcmp(s, "MUL") == 0) return MUL;
    if (strcmp(s, "DIV") == 0) return DIV;
    if (strcmp(s, "MOD") == 0) return MOD;
    if (strcmp(s, "SHL") == 0) return SHL;
    if (strcmp(s, "SHR") == 0) return SHR;
    if (strcmp(s, "XOR") == 0) return XOR;
    if (strcmp(s, "NOT") == 0) return NOT;
    if (strcmp(s, "JGT") == 0) return JGT;
    if (strcmp(s, "JLT") == 0) return JLT;
    if (strcmp(s, "RUN") == 0) return RUN;
    if (strcmp(s, "RET") == 0) return RET;
    if (strcmp(s, "LDI") == 0) return LDI;
    if (strcmp(s, "STI") == 0) return STI;
    if (strcmp(s, "ENT") == 0) return ENT;
    if (strcmp(s, "LEV") == 0) return LEV;
    if (strcmp(s, "LDB") == 0) return LDB;
    if (strcmp(s, "STB") == 0) return STB;
    if (strcmp(s, "RTI") == 0) return RTI;
    if (strcmp(s, "HLT") == 0) return HLT;

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
    if (strcmp(s, "DRAW_TEXT") == 0) return DRAW_TEXT;
    if (strcmp(s, "EXIT") == 0) return EXIT;

    return atoi(s);
}

void write32(FILE* f, int val) {
    uint8_t bytes[4];
    bytes[0] = val & 0xFF; bytes[1] = (val >> 8) & 0xFF;
    bytes[2] = (val >> 16) & 0xFF; bytes[3] = (val >> 24) & 0xFF;
    fwrite(bytes, 1, 4, f);
}

int process_file(const char* filename) {
    FILE *infile = fopen(filename, "r");
    if (!infile) { printf("Error: Could not open %s\n", filename); return 1; }
    char line[MAX_LINE_LEN];
    while (fgets(line, sizeof(line), infile)) {
        strip_comments(line);
        char *tok = strtok(line, " \t\n\r");
        while (tok != NULL) {
            if (strcmp(tok, ".DATA") == 0) current_section = 1;
            else if (strcmp(tok, ".TEXT") == 0) current_section = 0;
            else {
                if (tok[strlen(tok)-1] == ':') {
                    tok[strlen(tok)-1] = '\0';
                    strcpy(labels[label_count].name, tok);
                    labels[label_count].is_data = current_section;
                    labels[label_count].address = current_section ? data_token_count : text_token_count;
                    label_count++;
                } else {
                    strcpy(current_section ? data_tokens[data_token_count++] : text_tokens[text_token_count++], tok);
                }
            }
            tok = strtok(NULL, " \t\n\r");
        }
    }
    fclose(infile); return 0;
}

void write_token(FILE* outfile, char* tok) {
    for(int j=0; j<label_count; j++) {
        if(strcmp(tok, labels[j].name) == 0) {
            int abs_addr = base_address + (labels[j].is_data ? ((labels[j].address + 2) * 4) : ((labels[j].address + 2 + data_token_count) * 4));
            write32(outfile, abs_addr);
            return;
        }
    }
    write32(outfile, map_token(tok));
}

int main(int argc, char* argv[]) {
    if (argc < 3 || argc > 4) {
        printf("Usage: %s <input.asm> <output.bin> [base address]\n", argv[0]);
        return 1;
    }

    if (argc == 4) base_address = atoi(argv[3]);

    if (process_file(argv[1]) != 0) return 1;

    FILE *outfile = fopen(argv[2], "wb"); // Open in binary mode

    // Write initial JMP to skip data section
    write32(outfile, JMP);
    write32(outfile, base_address + ((data_token_count + 2) * 4));

    for (int i=0; i<data_token_count; i++) write_token(outfile, data_tokens[i]);
    for (int i=0; i<text_token_count; i++) write_token(outfile, text_tokens[i]);

    fclose(outfile);
    return 0;
}
