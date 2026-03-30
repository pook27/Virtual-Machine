#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_TOKENS 4096
#define MAX_TOKENS_LEN 32
#define MAX_LABELS 256
#define MAX_LINE_LEN 256

typedef struct {
    char name[MAX_TOKENS_LEN];
    int address;
} Label;

char tokens[MAX_TOKENS][MAX_TOKENS_LEN];
int token_count = 0;

Label labels[MAX_LABELS];
int label_count = 0;

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

    while (fgets(line, sizeof(line), infile)) {
        strip_comments(line);
        char *token = strtok(line, " \t\r\n,");

        while (token != NULL) {
            int len = strlen(token);
            //label checker
            if (len > 0 && token[len - 1] == ':') {
                if (label_count < MAX_LABELS) {
                    strncpy(labels[label_count].name, token, len - 1); //copies name of label without colon into the name field of the labels array
                    labels[label_count].name[len - 1] = '\0';
                    labels[label_count].address = token_count;
                    label_count++;
                } else {
                    printf("Error: Exceeded maximum number of labels (%d).\n", MAX_LABELS);
                    fclose(infile);
                    return 1;
                }
            } else { //standard instruction
                if (token_count < MAX_TOKENS) {
                    strncpy(tokens[token_count], token, MAX_TOKENS_LEN - 1);
                    tokens[token_count][MAX_TOKENS_LEN - 1] = '\0';
                    token_count++;
                } else {
                    printf("Error: Exceeded maximum number of tokens (%d).\n", MAX_TOKENS);
                    fclose(infile);
                    return 1;
                }
            }
            token = strtok(NULL, " \t\r\n,"); //get next token
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
