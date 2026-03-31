#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <termios.h>
#include <unistd.h>
#include <stdbool.h>

#define MAX_PROGRAMS 100
#define MAX_FILENAME_LEN 256

struct termios orig_termios;

void disable_raw_mode() {
    tcsetattr(STDIN_FILENO, TCSANOW, &orig_termios);
    printf("\033[?25h\033[0m"); // Show cursor, reset colors
    fflush(stdout);
}

void enable_raw_mode() {
    struct termios raw = orig_termios;
    raw.c_lflag &= ~(ICANON | ECHO); // Disable echoing and line buffering
    tcsetattr(STDIN_FILENO, TCSANOW, &raw);
    printf("\033[?25l"); // Hide cursor
    fflush(stdout);
}

int read_key() {
    char c;
    while (read(STDIN_FILENO, &c, 1) != 1);

    if (c == '\033') {
        char seq[3];
        if (read(STDIN_FILENO, &seq[0], 1) != 1) return '\033';
        if (read(STDIN_FILENO, &seq[1], 1) != 1) return '\033';

        if (seq[0] == '[') {
            switch (seq[1]) {
                case 'A': return 1000; // Up Arrow
                case 'B': return 1001; // Down Arrow
            }
        }
        return '\033';
    }
    return c;
}

int main() {
    char programs[MAX_PROGRAMS][MAX_FILENAME_LEN];
    int prog_count = 0;

    DIR *d;
    struct dirent *dir;
    d = opendir("programs");
    if (d) {
        while ((dir = readdir(d)) != NULL) {
            char *ext = strrchr(dir->d_name, '.');
            if (ext && strcmp(ext, ".asm") == 0) {
                if (prog_count < MAX_PROGRAMS) {
                    strncpy(programs[prog_count], dir->d_name, MAX_FILENAME_LEN);
                    prog_count++;
                }
            }
        }
        closedir(d);
    } else {
        printf("Error: Could not open 'programs' directory.\n");
        return 1;
    }

    if (prog_count == 0) {
        printf("No .asm files found in 'programs/'.\n");
        return 1;
    }

    int selected = 0;
    bool running = true;

    tcgetattr(STDIN_FILENO, &orig_termios);
    atexit(disable_raw_mode); 

    while (running) {
        enable_raw_mode();
        
        printf("\033[2J\033[H");
        printf("\033[1;36m======================================\033[0m\n");
        printf("\033[1;32m       VIRTUAL MACHINE LAUNCHER       \033[0m\n");
        printf("\033[1;36m======================================\033[0m\n");
        printf("\033[90m Use UP/DOWN to navigate, ENTER to run \033[0m\n");
        printf("\033[90m Press 'q' to quit out to terminal     \033[0m\n\n");

        for (int i = 0; i < prog_count; i++) {
            char display_name[MAX_FILENAME_LEN];
            strcpy(display_name, programs[i]);
            *strrchr(display_name, '.') = '\0';

            if (i == selected) {
                printf("  \033[1;33m> %s\033[0m\n", display_name);
            } else {
                printf("    \033[37m%s\033[0m\n", display_name);
            }
        }

        int c = read_key();
        if (c == 1000) {        // Up Arrow
            selected--;
            if (selected < 0) selected = prog_count - 1;
        } else if (c == 1001) { // Down Arrow
            selected++;
            if (selected >= prog_count) selected = 0;
        } else if (c == 'q') {  // Quit
            running = false;
        } else if (c == '\n' || c == '\r') { // Enter Key
            
            disable_raw_mode(); // Give control of the terminal back before launching
            printf("\033[2J\033[H"); // Clear screen

            char asm_file[MAX_FILENAME_LEN + 15];
            char vm_file[MAX_FILENAME_LEN + 15];
            
            sprintf(asm_file, "programs/%s", programs[selected]);
            
            strcpy(vm_file, asm_file);
            strcpy(strrchr(vm_file, '.'), ".vm");

            char assemble_cmd[1024];
            snprintf(assemble_cmd, sizeof(assemble_cmd), "./assembler %s %s", asm_file, vm_file);
            
            char run_cmd[1024];
            snprintf(run_cmd, sizeof(run_cmd), "./cpu %s", vm_file);

            printf("\033[36mRecompiling tools...\033[0m\n");
            system("make > /dev/null 2>&1"); // Suppress make output

            printf("\033[36mAssembling %s...\033[0m\n", asm_file);
            if (system(assemble_cmd) == 0) {
                // If assembly succeeded, run the VM
                system(run_cmd);
            } else {
                printf("\n\033[31mAssembly failed. Check your syntax.\033[0m\n");
            }

            // Wait for user to acknowledge before returning to the menu
            printf("\n\033[90mPress ENTER to return to the launcher...\033[0m");
            getchar(); 
        }
    }
    printf("\033[2J\033[H");
    return 0;
}
