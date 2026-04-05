#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

FILE *in, *out;
int cur_char;
char tok_text[256];
int tok_type; //1 Identifier 2 Number 3 Symbol 0 EOF

void next_char() {cur_char = fgetc(in);}
void skip_whitespace() {
    while (1) {
        if (isspace(cur_char)) {
            next_char();
        } else if (cur_char == '/') {
            int next = fgetc(in);
            if (next == '/') {
                while (cur_char != '\n' && cur_char != EOF) next_char();
            } else {
                ungetc(next, in); // False alarm, put the character back
                break;
            }
        } else {
            break;
        }
    }
}

void next_token() {
    skip_whitespace();
    if (cur_char == EOF) {tok_type = 0; return;}

    int len = 0;
    if(isalpha(cur_char) || cur_char == '_') {
        while(isalnum(cur_char) || cur_char == '_') {
            tok_text[len++] = cur_char; next_char();
        }
        tok_text[len] = '\0';
        tok_type = 1;
    } else if (isdigit(cur_char)) {
        while(isdigit(cur_char)) {
            tok_text[len++] = cur_char; next_char();
        }
        tok_text[len] = '\0';
        tok_type = 2;
    } else {
        tok_text[0] = cur_char; tok_text[1] = '\0';
        tok_type = 3; next_char();
    }
}

void parse() {
    fprintf(out, ".TEXT\nJMP MAIN_ENTRY\n\n");
    next_token();

    while (tok_type != 0) {
        // 1. Variable Declaration: int x = 5;
        if (tok_type == 1 && strcmp(tok_text, "int") == 0) {
            next_token(); char var_name[256]; strcpy(var_name, tok_text);
            next_token(); // Skip '='
            next_token(); char val[256]; strcpy(val, tok_text);
            next_token(); // Skip ';'
            fprintf(out, ".DATA\n%s: %s\n", var_name, val);
            next_token();
        }
        // 2. Main Function: void main() {
        else if (tok_type == 1 && strcmp(tok_text, "void") == 0) {
            next_token(); next_token(); next_token(); next_token(); // skip main(){
            fprintf(out, ".TEXT\nMAIN_ENTRY:\n");
            next_token();
        }
        // 3. Infinite Loop: while(1) {
        else if (tok_type == 1 && strcmp(tok_text, "while") == 0) {
            next_token(); next_token(); next_token(); next_token(); // skip (1){
            fprintf(out, "LOOP_START:\n");
            next_token();
        }
        // 4. End of Block: }
        else if (tok_type == 3 && strcmp(tok_text, "}") == 0) {
            fprintf(out, "    JMP LOOP_START\n");
            next_token();
        }
        // 5. SYSCALLS (Moved UP to protect them from the generic math block!)
        else if (tok_type == 1 && strcmp(tok_text, "sys_render") == 0) {
            next_token(); next_token(); next_token(); // Skip () and ;
            fprintf(out, "    MOV RS, 7\n    SYS\n\n");
            next_token();
        }
        else if (tok_type == 1 && strcmp(tok_text, "sys_clear") == 0) {
            next_token(); next_token(); next_token(); // Skip () and ;
            fprintf(out, "    MOV RS, 2\n    SYS\n\n");
            next_token();
        }
        else if (tok_type == 1 && strcmp(tok_text, "draw_pixel") == 0) {
            next_token(); // Skip (
            next_token(); char x[256]; strcpy(x, tok_text); int x_type = tok_type;
            next_token(); // Skip ,
            next_token(); char y[256]; strcpy(y, tok_text); int y_type = tok_type;
            next_token(); // Skip ,
            next_token(); char color[256]; strcpy(color, tok_text); int c_type = tok_type;
            next_token(); // Skip )
            next_token(); // Skip ;

            if(y_type == 2) fprintf(out, "    PSH %s\n", y); else fprintf(out, "    LOD %s\n", y);
            fprintf(out, "    PSH 320\n    MUL\n");
            
            if(x_type == 2) fprintf(out, "    PSH %s\n", x); else fprintf(out, "    LOD %s\n", x);
            fprintf(out, "    ADD\n");
            
            fprintf(out, "    PSH 1048576\n    ADD\n    PUT R3\n    DRP\n");
            
            if(c_type == 2) fprintf(out, "    PSH %s\n", color); else fprintf(out, "    LOD %s\n", color);
            fprintf(out, "    STB R3\n    DRP\n\n");
            next_token();
        }
        // 6. Math Assignment: x = y + z; (The Generic Fallback)
        else if (tok_type == 1) {
            char var_name[256]; strcpy(var_name, tok_text);
            next_token(); // Skip '='

            next_token(); char arg1[256]; strcpy(arg1, tok_text); int arg1_type = tok_type;
            next_token(); char op[256]; strcpy(op, tok_text);
            next_token(); char arg2[256]; strcpy(arg2, tok_text); int arg2_type = tok_type;
            next_token(); // Skip ';'

            if (arg1_type == 2) fprintf(out, "    PSH %s\n", arg1); else fprintf(out, "    LOD %s\n", arg1);
            if (arg2_type == 2) fprintf(out, "    PSH %s\n", arg2); else fprintf(out, "    LOD %s\n", arg2);

            if (strcmp(op, "+") == 0) fprintf(out, "    ADD\n");
            else if (strcmp(op, "-") == 0) fprintf(out, "    SUB\n");

            fprintf(out, "    PUT %s\n    DRP\n\n", var_name);
            next_token();
        } else {
            next_token(); // Failsafe skip
        }
    }
}
        int main(int argc, char** argv) {
            if (argc < 3) {
                printf("Usage: ./compiler <input.c> <output.asm>\n");
                return 1;
            }
            in = fopen(argv[1], "r");
            out = fopen(argv[2], "w");

            next_char();
            parse();

            fclose(in);
            fclose(out);
            printf("Successfully compiled %s to %s!\n", argv[1], argv[2]);
            return 0;
        }
