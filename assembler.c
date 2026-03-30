#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_TOKENS 4096
#define MAX_TOKENS_LEN 32
#define MAX_LABELS 256
#define MAX_LINE_LEN 256
#define MAX_MACROS 256

typedef struct {
    char name[MAX_TOKENS_LEN];
    int address;
} Label;

typedef struct {
    char name[MAX_TOKENS_LEN];
    char value[MAX_TOKENS_LEN];
} Macro;

char tokens[MAX_TOKENS][MAX_TOKENS_LEN];
int token_count = 0;

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

int main(int argc, char* argv[]) {
    if (argc != 3) {
        printf("Usage: %s <input.asm> <output.vm>\n", argv[0]);
        return 1;
    }

    FILE *infile = fopen(argv[1], "r");
    if (!infile) {
        printf("Error: Could not open input file %s\n", argv[1]);
        return 1;
    }

    char line[MAX_LINE_LEN];
    int line_num = 0;

    while (fgets(line, sizeof(line), infile)) {
        line_num++;
        strip_comments(line);

        char temp_line[MAX_LINE_LEN];
        strcpy(temp_line, line);

        char *cmd = strtok(temp_line, " \t\r\n,");
        if (cmd && strcmp(cmd, ".DEFINE") == 0) {
            char* mname = strtok(NULL, " \t\r\n,"); 
            char* mval = strtok(NULL, " \t\r\n,");
            if (mname && mval && macro_count < MAX_MACROS) {
                strcpy(macros[macro_count].name, mname);
                strcpy(macros[macro_count].value, mval);
                macro_count++;
            }
            continue;
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
                            sprintf(tokens[token_count++], "10"); // ASCII for Newline
                        } else if (*ptr == 't') {
                            sprintf(tokens[token_count++], "9");  // ASCII for Tab
                        } else if (*ptr == '"') {
                            sprintf(tokens[token_count++], "34"); // ASCII for Double Quote
                        } else if (*ptr == '\\') {
                            sprintf(tokens[token_count++], "92"); // ASCII for Backslash
                        } else {
                            sprintf(tokens[token_count++], "%d", *ptr); 
                        }
                    } else {
                        sprintf(tokens[token_count++], "%d", *ptr);
                    }
                    ptr++;
                }
                sprintf(tokens[token_count++], "0"); // Null terminator
                if (*ptr == '"') ptr++; // Skip closing quote
            }else {
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
                        strcpy(tokens[token_count++], macros[m].value);
                        is_macro = 1;
                        break;
                    }
                }
                if (is_macro) continue;

                int len = strlen(tok);
                if (len > 0 && tok[len-1] == ':') {
                    strncpy(labels[label_count].name, tok, len - 1);
                    labels[label_count].name[len - 1] = '\0';
                    labels[label_count].address = token_count;
                    label_count++;
                } else {
                    strcpy(tokens[token_count++], tok);
                }
            }
        }
    }
    fclose(infile);

    FILE *outfile = fopen(argv[2], "w");
    if (!outfile) {
        printf("Error: Could not open output file %s\n", argv[2]);
        return 1;
    }

    for(int i=0; i < token_count; i++) {
        int is_label_ref = 0;
        for(int j=0; j<label_count; j++) {
            if(strcmp(tokens[i], labels[j].name) == 0) { //check if it is a known label
                fprintf(outfile, "%d\n", labels[j].address);
                is_label_ref = 1;
                break;
            }
        }
        if (!is_label_ref) { //if not write directly the string content of the token as is
            fprintf(outfile, "%s\n", tokens[i]);
        }
    }
    fclose(outfile);
    printf("Succesfully assembled %s into %s\n", argv[1], argv[2]);
    return 0;
}
