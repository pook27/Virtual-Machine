// ==========================================
// KERNEL.C - Bulletproof Global Syscalls
// ==========================================
char *vram = (char *)1048576;
char *keys = (char *)2097152;
char *font = (char *)100000;

// By using globals, we bypass the C calling convention 
// stack offsets entirely, preventing stack corruption!
int sys_rx = 0;
int sys_ry = 0;
int sys_rc = 0;

struct DirectoryEntry {
    char name[24];
    int start_sector;
    int size_in_bytes;
};

// Pure inline assembly subroutine
void _do_disk_read() {
    asm("LOD sys_rx"); asm("PUT RX"); asm("DRP");
    asm("LOD sys_ry"); asm("PUT RY"); asm("DRP");
    asm("LOD sys_rc"); asm("PUT RC"); asm("DRP");
    asm("MOV RS, DISK_READ"); 
    asm("SYS");
}

// C wrapper that safely populates the globals
void disk_read(int sector, char *dest, int count) {
    sys_rx = sector;
    sys_ry = (int)dest;
    sys_rc = count;
    _do_disk_read();
}

void render() {
    asm("MOV RS, RENDER"); 
    asm("SYS");
}

// --- Graphics Helpers ---
void draw_char(int x, int y, int ascii, int color) {
    int font_offset = ascii * 8;
    for (int r = 0; r < 8; r = r + 1) {
        int row_val = font[font_offset + r];
        for (int c = 0; c < 8; c = c + 1) {
            if ((row_val >> (7 - c)) & 1) {
                vram[((y + r) * 320) + (x + c)] = color;
            }
        }
    }
}

void draw_string(int x, int y, char *str, int color) {
    int cursor_x = x;
    for (int i = 0; str[i] != 0; i = i + 1) {
        draw_char(cursor_x, y, str[i], color);
        cursor_x = cursor_x + 8;
    }
}

// --- Main Kernel Logic ---
int main() {
    // Debug: Force a red pixel instantly to prove we reached the Kernel!
    vram[0] = 200; 
    render();

    // 1. Load the system font from Sector 10 into memory at 10000
    disk_read(65, font, 4);

    // 2. Read Sector 9 (Directory Table) into a local array
    struct DirectoryEntry dir[16];
    disk_read(64, (char *)dir, 1); 

    // 3. Draw the UI
    draw_string(10, 10, "CUSTOM OS KERNEL", 255);
    draw_string(10, 25, "Select a program:", 200);

    int valid_files = 0;
    int y_pos = 45;

    for (int i = 0; i < 16; i = i + 1) {
        if (dir[i].name[0] != 0) {
            draw_char(10, y_pos, 48 + i, 255);
            draw_string(20, y_pos, "-", 255);
            draw_string(30, y_pos, dir[i].name, 255);
            y_pos = y_pos + 10;
            valid_files = valid_files + 1;
        }
    }
    render();

    // 4. Poll keyboard for a selection
    int selected_index = -1;
    while (selected_index == -1) {
        for (int k = 0; k < valid_files; k = k + 1) {
            if (keys[48 + k]) {
                selected_index = k;
            }
        }
        render(); // Must render to poll the keyboard array!
    }

    // 5. Load the program into memory address 200000
    int target_sector = dir[selected_index].start_sector;
    int size = dir[selected_index].size_in_bytes;
    int sectors_to_read = (size / 512) + 1;
    char *program_ram = (char *)200000;  // Moved program load target
    
    disk_read(target_sector, program_ram, sectors_to_read);

    // 6. Clear the screen before launching
    for (int i = 0; i < 64000; i = i + 1) {
        vram[i] = 0;
    }
    render();

    // 7. JUMP TO THE LOADED PROGRAM
    // (This elegantly abandons the Kernel stack and jumps to address 20000)
    asm("PSH 200000");
    asm("RET"); 

    return 0;
}
