#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_TOKENS 8192
#define MAX_TOKENS_LEN 32
#define MAX_LABELS 256
#define MAX_LINE_LEN 256
#define MAX_MACROS 256

typedef struct {
    char name[MAX_TOKENS_LEN];
    int address;
    int is_data;
} Label;

typedef struct {
    char name[MAX_TOKENS_LEN];
    char value[MAX_TOKENS_LEN];
} Macro;

char data_tokens[MAX_TOKENS][MAX_TOKENS_LEN];
int data_token_count = 0;

char text_tokens[MAX_TOKENS][MAX_TOKENS_LEN];
int text_token_count = 0;

int current_section = 0; //0 for .TEXT 1 for .DATA

Label labels[MAX_LABELS];
int label_count = 0;

Macro macros[MAX_MACROS];
int macro_count = 0;

void strip_comments(char *line) {
    char *comment_pos = strchr(line, ';');
    if (comment_pos != NULL)
    {
        *comment_pos = '\0';
    }
}

int process_file(const char* filename) {
    FILE *infile = fopen(filename, "r");
    if (!infile) {
        printf("Error: Could not open %s\n", filename);
        return 1;
    }

    char line[MAX_LINE_LEN];
    while (fgets(line, sizeof(line), infile)) {
        strip_comments(line);

        char temp_line[MAX_LINE_LEN];
        strcpy(temp_line, line);
        char *cmd = strtok(temp_line, " \t\r\n,");

        if (cmd) {
            if (strcmp(cmd, ".DEFINE") == 0) {
                char* mname = strtok(NULL, " \t\r\n,"); 
                char* mval = strtok(NULL, " \t\r\n,");
                if (mname && mval && macro_count < MAX_MACROS) {
                    strcpy(macros[macro_count].name, mname);
                    strcpy(macros[macro_count].value, mval);
                    macro_count++;
                }
                continue;
            }
            if (strcmp(cmd, "%include") == 0) {
                char* inc_file = strtok(NULL, " \t\r\n,");
                if (inc_file) {
                    if (inc_file[0] == '"') inc_file++;
                    int len = strlen(inc_file);
                    if (inc_file[len-1] == '"') inc_file[len-1] = '\0';
                    process_file(inc_file);
                }
                continue;
            }
            if (strcmp(cmd, ".DATA") == 0) { current_section = 1; continue; }
            if (strcmp(cmd, ".TEXT") == 0) { current_section = 0; continue; }
        }

        char* ptr = line;
        while(*ptr) {
            while (*ptr == ' ' || *ptr == '\t' || *ptr == '\r' || *ptr == '\n' || *ptr == ',') ptr++;
            if (*ptr == '\0') break;

            if (*ptr == '"') {
                ptr++;
                while(*ptr != '\0' && *ptr != '"') {
                    if (*ptr == '\\') {
                        ptr++;
                        if (*ptr == 'n') {
                            sprintf(current_section ? data_tokens[data_token_count++] : text_tokens[text_token_count++], "10");  // ASCII for Newline
                        } else if (*ptr == 't') {
                            sprintf(current_section ? data_tokens[data_token_count++] : text_tokens[text_token_count++], "9");  // ASCII for Tab
                        } else if (*ptr == '"') {
                            sprintf(current_section ? data_tokens[data_token_count++] : text_tokens[text_token_count++], "34");  // ASCII for Double Quote
                        } else if (*ptr == '\\') {
                            sprintf(current_section ? data_tokens[data_token_count++] : text_tokens[text_token_count++], "92");  // ASCII for Backslash
                        }else {
                            sprintf(current_section ? data_tokens[data_token_count++] : text_tokens[text_token_count++], "%d", *ptr); 
                        }
                    } else {
                        sprintf(current_section ? data_tokens[data_token_count++] : text_tokens[text_token_count++], "%d", *ptr);
                    }
                    ptr++;
                }
                sprintf(current_section ? data_tokens[data_token_count++] : text_tokens[text_token_count++], "0"); 
                if (*ptr == '"') ptr++; 
            } else {
                char tok[MAX_TOKENS_LEN];
                int k = 0;
                while (*ptr != ' ' && *ptr != '\t' && *ptr != '\r' && *ptr != '\n' && *ptr != ',' && *ptr != '"' && *ptr != '\0') {
                    tok[k++] = *ptr++;
                }
                tok[k] = '\0';

                if (strcmp(tok, ".STRING") == 0) continue;

                int is_macro = 0;
                for(int m = 0; m<macro_count; m++) {
                    if (strcmp(tok, macros[m].name) == 0) {
                        strcpy(current_section ? data_tokens[data_token_count++] : text_tokens[text_token_count++], macros[m].value);
                        is_macro = 1;
                        break;
                    }
                }
                if (is_macro) continue;

                int len = strlen(tok);
                if (len > 2 && tok[0] == '[' && tok[len-1] == ']') {
                    char reg_name[MAX_TOKENS_LEN];
                    strncpy(reg_name, tok + 1, len - 2);
                    reg_name[len - 2] = '\0';

                    int* count = current_section ? &data_token_count : &text_token_count;
                    char (*token_arr)[MAX_TOKENS_LEN] = current_section ? data_tokens : text_tokens;

                    if (*count > 0) {
                        if (strcmp(token_arr[*count - 1], "LOD") == 0) strcpy(token_arr[*count - 1], "LDI");
                        else if (strcmp(token_arr[*count - 1], "PUT") == 0) strcpy(token_arr[*count - 1], "STI");
                    }
                    strcpy(token_arr[(*count)++], reg_name);
                } 
                else if (len > 0 && tok[len-1] == ':') {
                    strncpy(labels[label_count].name, tok, len - 1);
                    labels[label_count].name[len - 1] = '\0';
                    labels[label_count].is_data = current_section;
                    labels[label_count].address = current_section ? data_token_count : text_token_count;
                    label_count++;
                } else {
                    strcpy(current_section ? data_tokens[data_token_count++] : text_tokens[text_token_count++], tok);
                }
            }
        }
    }
    fclose(infile);
    return 0;
}

void write_token(FILE* outfile, char* tok) {
    for(int j=0; j<label_count; j++) {
        if(strcmp(tok, labels[j].name) == 0) {
            int abs_addr = labels[j].is_data ? (labels[j].address + 2) : (labels[j].address + 2 + data_token_count);
            fprintf(outfile, "%d\n", abs_addr);
            return;
        }
    }
    fprintf(outfile, "%s\n", tok);
}

int main(int argc, char* argv[]) {
    if (argc != 3) {
        printf("Usage: %s <input.asm> <output.vm>\n", argv[0]);
        return 1;
    }

    if (process_file(argv[1]) != 0) return 1;

    FILE *outfile = fopen(argv[2], "w");

    // Automatically write a JMP instruction to jump over all .DATA into the .TEXT segment
    fprintf(outfile, "JMP\n");
    fprintf(outfile, "%d\n", data_token_count + 2); // Jump target

    for(int i=0; i < data_token_count; i++) write_token(outfile, data_tokens[i]);
    for(int i=0; i < text_token_count; i++) write_token(outfile, text_tokens[i]);

    fclose(outfile);
    printf("Successfully assembled %s into %s\n", argv[1], argv[2]);
    return 0;
}
