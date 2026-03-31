#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <raylib.h>
#include <unistd.h>
#include <stdbool.h>

#define MAX_PROGRAMS 100
#define MAX_FILENAME_LEN 256

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

    InitWindow(640, 480, "VM OS - System Launcher");
    SetTargetFPS(60);

    while (running && !WindowShouldClose()) {
        
        if (IsKeyPressed(KEY_UP)) {
            selected--;
            if (selected < 0) selected = prog_count - 1;
        }
        if (IsKeyPressed(KEY_DOWN)) {
            selected++;
            if (selected >= prog_count) selected = 0;
        }
        if (IsKeyPressed(KEY_Q)) {
            running = false;
        }
        
        if (IsKeyPressed(KEY_ENTER)) {
            CloseWindow(); 

            char asm_file[MAX_FILENAME_LEN + 15];
            char vm_file[MAX_FILENAME_LEN + 15];
            
            sprintf(asm_file, "programs/%s", programs[selected]);
            strcpy(vm_file, asm_file);
            strcpy(strrchr(vm_file, '.'), ".vm");

            char assemble_cmd[1024];
            snprintf(assemble_cmd, sizeof(assemble_cmd), "./assembler %s %s", asm_file, vm_file);
            
            char run_cmd[1024];
            snprintf(run_cmd, sizeof(run_cmd), "./cpu %s", vm_file);

            system("make > /dev/null 2>&1"); 
            
            if (system(assemble_cmd) == 0) {
                system(run_cmd);
            } else {
                printf("\nAssembly failed for %s. Check your syntax.\n", asm_file);
                printf("Press ENTER to return to launcher...\n");
                getchar();
            }

            InitWindow(640, 480, "VM OS - System Launcher");
            SetTargetFPS(60);
        }

        if (!IsWindowReady()) continue; // Safety check during transitions

        BeginDrawing();
        ClearBackground((Color){ 20, 20, 30, 255 }); // Dark blueish-gray background

        DrawText("VIRTUAL MACHINE OS", 180, 40, 24, RAYWHITE);
        DrawText("Select a program to boot", 215, 75, 16, LIGHTGRAY);
        DrawLine(100, 110, 540, 110, GRAY);

        int start_y = 140;
        for (int i = 0; i < prog_count; i++) {
            char display_name[MAX_FILENAME_LEN];
            strcpy(display_name, programs[i]);
            *strrchr(display_name, '.') = '\0';

            int y_pos = start_y + (i * 35);

            if (i == selected) {
                DrawText(">", 180, y_pos, 20, YELLOW);
                DrawText(display_name, 210, y_pos, 20, YELLOW);
            } else {
                DrawText(display_name, 210, y_pos, 20, DARKGRAY);
            }
        }

        DrawLine(100, 410, 540, 410, GRAY);
        DrawText("UP/DOWN: Navigate   ENTER: Boot   Q: Shutdown", 130, 430, 14, GRAY);
        EndDrawing();
    }
    if (IsWindowReady()) CloseWindow();
    return 0;
}
