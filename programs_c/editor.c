char *vram = (char *)1048576; // <--- Restored!
char *keys = (char *)2097152;
char *font = (char *)10000;
int *RC = (int *)8388376; 

void draw_char(int x, int y, int ascii, int color);
void disk_read(int sector, char *dest, int count);
void disk_write(int sector, char *src, int count);

struct DirectoryEntry {
    char name[24];
    int start_sector;
    int size_in_bytes;
};

void save_file(char *filename, char *file_data, int data_length) {
    char dir_table[512];
    disk_read(9, dir_table, 1);
    
    struct DirectoryEntry *entries = (struct DirectoryEntry *)dir_table;
    
    int target_slot = -1;
    int next_free_sector = 10; 
    
    for (int i = 0; i < 16; i++) {
        if (entries[i].name[0] == 0) {
            if ( target_slot == -1)
                target_slot = i;
        }
        if (entries[i].name[0] != 0) {
            int sectors_used = (entries[i].size_in_bytes / 512) + 1;
            next_free_sector = entries[i].start_sector + sectors_used;
        }
    }
    
    if (target_slot == -1) return; 
    
    for (int c = 0; c < 24; c++) entries[target_slot].name[c] = filename[c];
    entries[target_slot].start_sector = next_free_sector;
    entries[target_slot].size_in_bytes = data_length;
    
    disk_write(9, dir_table, 1);
    
    int sectors_needed = (data_length / 512) + 1;
    //disk_write(next_free_sector, file_data, sectors_needed);
}

int main() {
    int cursor_x = 10;
    int cursor_y = 10;

    // --- NEW: The Document Buffer! ---
    // This stores what we type in RAM so we can save it later.
    char text_buffer[8192];
    int text_length = 0;

    asm("MOV RS, 2"); 
    asm("SYS");

    while (1) {
        draw_char(cursor_x, cursor_y, 95, 255); 

        asm("MOV RS, 7"); 
        asm("SYS");

        // Save and Exit (Escape Key)
        if (keys[256]) {
            // Write our RAM buffer to the hard drive as "my_doc"!
            save_file("my_doc", text_buffer, text_length);
            break;
        }

        // Hardware Enter Key
        if (keys[257]) { 
            draw_char(cursor_x, cursor_y, 95, 0); 
            cursor_x = 10;
            cursor_y = cursor_y + 12;
            
            // Save the newline to our buffer
            text_buffer[text_length] = '\n';
            text_length = text_length + 1;

            while(keys[257]) { asm("MOV RS, 7"); asm("SYS"); } 
        }

        *RC = 0;          
        asm("MOV RS, 6"); 
        asm("SYS");
        int key = *RC;    

        if (key > 0) {
            draw_char(cursor_x, cursor_y, 95, 0); 
            draw_char(cursor_x, cursor_y, key, 255); 
            cursor_x = cursor_x + 10;
            
            // Save the typed character to our buffer!
            text_buffer[text_length] = key;
            text_length = text_length + 1;
            
            if (cursor_x > 300) { 
                cursor_x = 10;
                cursor_y = cursor_y + 12;
            }
        }
    }
    return 0;
}

void draw_char(int x, int y, int ascii, int color) {
    for (int r = 0; r < 8; r++) {
        int row_val = font[(ascii * 8) + r];
        for (int c = 0; c < 8; c++) {
            if ((row_val >> (7 - c)) & 1) {
                vram[((y + r) * 320) + (x + c)] = color;
            }
        }
    }
}

// =========================================
// THE HARDWARE I/O BRIDGE
// =========================================
void disk_read(int sector, char *dest, int count) {
    // Load Sector (FP + 16) into RX
    asm("LOD FP"); asm("PSH 16"); asm("ADD"); asm("PUT R3"); asm("DRP"); asm("LDI R3"); asm("PUT RX"); asm("DRP");
    // Load Dest Pointer (FP + 12) into RY
    asm("LOD FP"); asm("PSH 12"); asm("ADD"); asm("PUT R3"); asm("DRP"); asm("LDI R3"); asm("PUT RY"); asm("DRP");
    // Load Count (FP + 8) into RC
    asm("LOD FP"); asm("PSH 8"); asm("ADD"); asm("PUT R3"); asm("DRP"); asm("LDI R3"); asm("PUT RC"); asm("DRP");
    
    // Trigger Hardware Disk Read
    asm("MOV RS, DISK_READ");
    asm("SYS");
}

void disk_write(int sector, char *src, int count) {
    // Load Sector (FP + 16) into RX
    asm("LOD FP"); asm("PSH 16"); asm("ADD"); asm("PUT R3"); asm("DRP"); asm("LDI R3"); asm("PUT RX"); asm("DRP");
    // Load Src Pointer (FP + 12) into RY
    asm("LOD FP"); asm("PSH 12"); asm("ADD"); asm("PUT R3"); asm("DRP"); asm("LDI R3"); asm("PUT RY"); asm("DRP");
    // Load Count (FP + 8) into RC
    asm("LOD FP"); asm("PSH 8"); asm("ADD"); asm("PUT R3"); asm("DRP"); asm("LDI R3"); asm("PUT RC"); asm("DRP");
    
    // Trigger Hardware Disk Write
    asm("MOV RS, DISK_WRITE");
    asm("SYS");
}
