#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "vm.h"

#define MAX_TOKENS 8192
#define MAX_TOKENS_LEN 32
#define MAX_LABELS 256
#define MAX_LINE_LEN 256
#define MAX_MACROS 256

typedef struct { char name[MAX_TOKENS_LEN]; int address; int is_data; } Label;
typedef struct { char name[MAX_TOKENS_LEN]; char value[MAX_TOKENS_LEN]; } Macro;

char data_tokens[MAX_TOKENS][MAX_TOKENS_LEN];
int  data_token_lines[MAX_TOKENS];          // ← line number each data token came from
int  data_token_count = 0;

char text_tokens[MAX_TOKENS][MAX_TOKENS_LEN];
int  text_token_lines[MAX_TOKENS];          // ← line number each text token came from
int  text_token_count = 0;

int current_section = 0;  // 0 = .TEXT, 1 = .DATA
int base_address    = 0;
int current_line    = 0;  // ← global line counter (accumulates across %include files)

Label labels[MAX_LABELS]; int label_count = 0;
Macro macros[MAX_MACROS]; int macro_count = 0;

// -------------------------------------------------------
// Returns 1 if s is a valid decimal integer (optional '-')
// -------------------------------------------------------
int is_valid_number(const char *s) {
    if (!s || !*s) return 0;
    int i = 0;
    if (s[0] == '-') i = 1;
    if (!s[i]) return 0;                   // just "-" is not a number
    for (; s[i]; i++) {
        if (s[i] < '0' || s[i] > '9') return 0;
    }
    return 1;
}

void strip_comments(char *line) {
    char *p = strchr(line, ';');
    if (p) *p = '\0';
}

int map_token(char *s) {
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

    if (strcmp(s, "CHAR")       == 0) return CHAR;
    if (strcmp(s, "CLEAR")      == 0) return CLEAR;
    if (strcmp(s, "DRAW")       == 0) return DRAW;
    if (strcmp(s, "SLEEP")      == 0) return SLEEP;
    if (strcmp(s, "STRING")     == 0) return STRING;
    if (strcmp(s, "INPUT")      == 0) return INPUT;
    if (strcmp(s, "RENDER")     == 0) return RENDER;
    if (strcmp(s, "DISK_READ")  == 0) return DISK_READ;
    if (strcmp(s, "DISK_WRITE") == 0) return DISK_WRITE;
    if (strcmp(s, "EXIT")       == 0) return EXIT;

    return atoi(s);
}

void write32(FILE *f, int val) {
    uint8_t b[4];
    b[0] = val & 0xFF; b[1] = (val >> 8) & 0xFF;
    b[2] = (val >> 16) & 0xFF; b[3] = (val >> 24) & 0xFF;
    fwrite(b, 1, 4, f);
}

// -------------------------------------------------------
// Store a token (and its source line) into the right buffer
// -------------------------------------------------------
static void store_token(const char *tok) {
    if (current_section) {
        strcpy(data_tokens[data_token_count], tok);
        data_token_lines[data_token_count] = current_line;
        data_token_count++;
    } else {
        strcpy(text_tokens[text_token_count], tok);
        text_token_lines[text_token_count] = current_line;
        text_token_count++;
    }
}

int process_file(const char *filename) {
    FILE *infile = fopen(filename, "r");
    if (!infile) { fprintf(stderr, "Error: Could not open %s\n", filename); return 1; }

    char line[MAX_LINE_LEN];
    while (fgets(line, sizeof(line), infile)) {
        current_line++;                      // ← increment per source line
        strip_comments(line);

        char *tok = strtok(line, " \t\n\r,");
        while (tok != NULL) {
            if (strcmp(tok, ".DATA") == 0) {
                current_section = 1;
            } else if (strcmp(tok, ".TEXT") == 0) {
                current_section = 0;
            } else if (strcmp(tok, ".DEFINE") == 0) {
                char *name = strtok(NULL, " \t\n\r,");
                char *val  = strtok(NULL, " \t\n\r,");
                if (name && val && macro_count < MAX_MACROS) {
                    strcpy(macros[macro_count].name, name);
                    strcpy(macros[macro_count].value, val);
                    macro_count++;
                }
            } else if (strcmp(tok, ".STRING") == 0) {
                char *q = strtok(NULL, "\"");
                if (q) {
                    while (*q) {
                        char buf[MAX_TOKENS_LEN];
                        if (*q == '\\' && *(q + 1)) {
                            q++;
                            int ch;
                            if      (*q == 'n')  ch = 10;
                            else if (*q == 't')  ch = 9;
                            else if (*q == '"')  ch = 34;
                            else if (*q == '\\') ch = 92;
                            else                 ch = *q;
                            sprintf(buf, "%d", ch);
                        } else {
                            sprintf(buf, "%d", (unsigned char)*q);
                        }
                        store_token(buf);
                        q++;
                    }
                }
                store_token("0");  // null terminator
                break;
            } else if (strcmp(tok, "%include") == 0) {
                char *inc = strtok(NULL, " \t\n\r,\"");
                if (inc) process_file(inc);
                break;
            } else {
                // Label definition?
                if (tok[strlen(tok) - 1] == ':') {
                    tok[strlen(tok) - 1] = '\0';
                    strcpy(labels[label_count].name, tok);
                    labels[label_count].is_data  = current_section;
                    labels[label_count].address  = current_section
                                                     ? data_token_count
                                                     : text_token_count;
                    label_count++;
                } else {
                    // Macro expansion?
                    int is_macro = 0;
                    for (int m = 0; m < macro_count; m++) {
                        if (strcmp(tok, macros[m].name) == 0) {
                            store_token(macros[m].value);
                            is_macro = 1;
                            break;
                        }
                    }
                    if (!is_macro) store_token(tok);
                }
            }
            tok = strtok(NULL, " \t\n\r,");
        }
    }
    fclose(infile);
    return 0;
}

// -------------------------------------------------------
// Write one token to the output file.
// Reports an error if the token is unrecognised.
// -------------------------------------------------------
void write_token(FILE *outfile, char *tok, int line_num) {
    // Is it a label reference?
    for (int j = 0; j < label_count; j++) {
        if (strcmp(tok, labels[j].name) == 0) {
            int abs_addr = base_address + (
                labels[j].is_data
                    ? ((labels[j].address + 2) * 4)
                    : ((labels[j].address + 2 + data_token_count) * 4)
            );
            write32(outfile, abs_addr);
            return;
        }
    }

    int val = map_token(tok);

    // ── Error detection ──────────────────────────────────────────
    // map_token returns 0 for anything it doesn't recognise (via
    // atoi fallback).  If the result is 0 but the token isn't the
    // literal "0" and isn't a valid number, it's a bug.
    if (val == 0 && strcmp(tok, "0") != 0 && strcmp(tok, "PSH") != 0 && !is_valid_number(tok)) {
        fprintf(stderr,
            "assembler error: line %d: unknown token '%s'"
            " — did you mean a label or instruction? (assembled as 0)\n",
            line_num, tok);
    }

    write32(outfile, val);
}

int main(int argc, char *argv[]) {
    if (argc < 3 || argc > 4) {
        printf("Usage: %s <input.asm> <output.bin> [base address]\n", argv[0]);
        return 1;
    }
    if (argc == 4) base_address = atoi(argv[3]);

    if (process_file(argv[1]) != 0) return 1;

    FILE *outfile = fopen(argv[2], "wb");
    if (!outfile) { fprintf(stderr, "Error: Cannot open %s for writing\n", argv[2]); return 1; }

    // Auto-generated JMP to skip the data section
    write32(outfile, JMP);
    write32(outfile, base_address + ((data_token_count + 2) * 4));

    for (int i = 0; i < data_token_count; i++)
        write_token(outfile, data_tokens[i], data_token_lines[i]);
    for (int i = 0; i < text_token_count; i++)
        write_token(outfile, text_tokens[i], text_token_lines[i]);

    fclose(outfile);
    return 0;
}
