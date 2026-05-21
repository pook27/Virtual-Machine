// =====================================================
// EDITOR.C  —  text editor with save-as and open
//
// Controls (edit mode):
//   ESC        → prompt "Save as: _"  (Enter confirms)
//   F5 (294)   → prompt "Open: _"     (Enter loads)
//   Enter      → newline
//   Backspace  → delete last char / last filename char
//   Any key    → type character
//
// In a prompt:
//   ESC        → cancel, back to edit mode
//   Enter      → confirm action
//   Backspace  → delete last filename char
// =====================================================

char *vram = (char *)1048576;
char *keys = (char *)2097152;
char *font = (char *)10000;
int  *RC   = (int  *)8388376;

// ---- forward declarations ----
void draw_char(int x, int y, int ascii, int color);
void disk_read(int sector, char *dest, int count);
void disk_write(int sector, char *src,  int count);

// ---- directory entry layout (32 bytes total) ----
struct DirectoryEntry {
    char name[24];         // bytes 0-23: null-terminated filename
    int  start_sector;     // bytes 24-27
    int  size_in_bytes;    // bytes 28-31
};

// =====================================================
// HELPERS
// =====================================================

// Draw a null-terminated string at (x,y).
void draw_str(int x, int y, char *s, int color) {
    int i = 0;
    while (s[i] != 0) {
        draw_char(x, y, s[i], color);
        x = x + 8;
        i = i + 1;
    }
}

// Erase a horizontal band (used to redraw the status bar).
void clear_band(int y, int h) {
    for (int row = y; row < y + h; row = row + 1) {
        for (int col = 0; col < 320; col = col + 1) {
            vram[row * 320 + col] = 0;
        }
    }
}

// Return 1 if two null-terminated strings are equal, 0 otherwise.
int str_eq(char *a, char *b) {
    int i = 0;
    while (a[i] != 0 && b[i] != 0) {
        if (a[i] != b[i]) return 0;
        i = i + 1;
    }
    if (a[i] == 0 && b[i] == 0) return 1;
    return 0;
}

// =====================================================
// DIRECTORY HELPERS
// =====================================================

// Scan dir_buf (512-byte sector 9) for a file named `name`.
// On success: sets *out_sector, *out_size and returns the slot index.
// Returns -1 if not found.
int dir_find(char *dir_buf, char *name, int *out_sector, int *out_size) {
    struct DirectoryEntry *e = (struct DirectoryEntry *)dir_buf;
    for (int i = 0; i < 16; i = i + 1) {
        if (e[i].name[0] != 0 && str_eq(e[i].name, name)) {
            *out_sector = e[i].start_sector;
            *out_size   = e[i].size_in_bytes;
            return i;
        }
    }
    return -1;
}

// Save `length` bytes from `data` into a file called `name`.
// Finds an empty or existing slot, allocates sectors, writes data.
// Multi-sector writes loop one call per sector (cpu.c writes 512 B/call).
void do_save(char *dir_buf, char *name, char *data, int length) {
    struct DirectoryEntry *e = (struct DirectoryEntry *)dir_buf;

    int existing_slot = -1;
    int empty_slot    = -1;
    int free_sector   = 11;   // sector 10 = font.bin; user files start at 11

    for (int i = 0; i < 16; i = i + 1) {
        if (e[i].name[0] != 0) {
            // Track where the next free sector is
            int used = (e[i].size_in_bytes / 512) + 1;
            if (e[i].start_sector + used > free_sector) {
                free_sector = e[i].start_sector + used;
            }
            // Is this the file we're overwriting?
            if (str_eq(e[i].name, name)) {
                existing_slot = i;
            }
        } else {
            if (empty_slot == -1) empty_slot = i;
        }
    }

    // Choose the directory slot
    int slot;
    int target_sector;
    if (existing_slot >= 0) {
        slot          = existing_slot;
        target_sector = e[existing_slot].start_sector;  // overwrite in place
    } else {
        slot          = empty_slot;
        target_sector = free_sector;
    }
    if (slot == -1) return;   // directory full – do nothing

    // Update the directory entry
    for (int c = 0; c < 24; c = c + 1) e[slot].name[c] = name[c];
    e[slot].start_sector  = target_sector;
    e[slot].size_in_bytes = length;

    // Flush directory back to disk
    disk_write(9, dir_buf, 1);

    // Write file data one sector at a time
    int sectors = (length / 512) + 1;
    for (int s = 0; s < sectors; s = s + 1) {
        disk_write(target_sector + s, data + (s * 512), 1);
    }
}

// =====================================================
// SCREEN / DOCUMENT HELPERS
// =====================================================

// Replay the document buffer and redraw every character.
// Sets *out_cx / *out_cy to where the cursor should land.
void redraw_doc(char *text, int len, int *out_cx, int *out_cy) {
    asm("MOV RS, 2"); asm("SYS");   // clear screen
    int x = 10;
    int y = 10;
    for (int i = 0; i < len; i = i + 1) {
        int ch = text[i];
        if (ch == 10) {             // '\n'
            x = 10;
            y = y + 12;
        } else {
            draw_char(x, y, ch, 255);
            x = x + 10;
            if (x > 300) { x = 10; y = y + 12; }
        }
    }
    *out_cx = x;
    *out_cy = y;
}

// =====================================================
// MAIN
// =====================================================
int main() {
    int cx   = 10;
    int cy   = 10;
    int mode = 0;        // 0 = edit | 1 = save-as prompt | 2 = open prompt

    char text_buf[8192];
    int  text_len = 0;

    char fname[24];
    int  fn_len = 0;

    char dir_buf[512];

    // Zero the text buffer
    for (int i = 0; i < 8192; i = i + 1) text_buf[i] = 0;
    for (int i = 0; i < 24;   i = i + 1) fname[i]    = 0;

    asm("MOV RS, 2"); asm("SYS");   // clear screen

    while (1) {

        // ---- status bar (bottom 12 pixels) ----
        clear_band(188, 12);
        if (mode == 0) {
            draw_str(0, 189, "ESC:save  F5:open  BS:del", 73);
        } else if (mode == 1) {
            draw_str(0, 189, "Save as:", 115);
            draw_str(80, 189, fname, 255);
        } else {
            draw_str(0, 189, "Open:", 115);
            draw_str(56, 189, fname, 255);
        }

        // Blinking cursor only in edit mode
        if (mode == 0) {
            draw_char(cx, cy, 95, 255);     // '_'
        }

        asm("MOV RS, 7"); asm("SYS");   // render

        // ---- ESC ----
        if (keys[256]) {
            if (mode == 0) {
                // Enter save-as prompt
                for (int i = 0; i < 24; i = i + 1) fname[i] = 0;
                fn_len = 0;
                mode = 1;
            } else {
                // Cancel prompt
                mode = 0;
            }
            while (keys[256]) { asm("MOV RS, 7"); asm("SYS"); }
        }

        // ---- F5 (Raylib key 294) — open prompt ----
        if (keys[294]) {
            if (mode == 0) {
                for (int i = 0; i < 24; i = i + 1) fname[i] = 0;
                fn_len = 0;
                mode = 2;
            }
            while (keys[294]) { asm("MOV RS, 7"); asm("SYS"); }
        }

        // ---- Backspace (Raylib key 259) ----
        if (keys[259]) {
            if (mode == 0) {
                if (text_len > 0) {
                    text_len = text_len - 1;
                    text_buf[text_len] = 0;
                    // Erase cursor, step back one cell, erase the character
                    draw_char(cx, cy, 95, 0);
                    cx = cx - 10;
                    if (cx < 10) cx = 10;
                    draw_char(cx, cy, 32, 0);
                }
            } else {
                if (fn_len > 0) {
                    fn_len = fn_len - 1;
                    fname[fn_len] = 0;
                }
            }
            while (keys[259]) { asm("MOV RS, 7"); asm("SYS"); }
        }

        // ---- Enter (Raylib key 257) ----
        if (keys[257]) {
            if (mode == 1) {
                // ---- SAVE ----
                if (fn_len > 0) {
                    disk_read(9, dir_buf, 1);
                    do_save(dir_buf, fname, text_buf, text_len);
                    // Show brief confirmation
                    clear_band(188, 12);
                    draw_str(0, 189, "Saved!", 115);
                    asm("MOV RS, 7"); asm("SYS");
                    // Short delay loop
                    for (int t = 0; t < 30; t = t + 1) {
                        asm("MOV RS, 7"); asm("SYS");
                    }
                }
                mode = 0;

            } else if (mode == 2) {
                // ---- OPEN ----
                if (fn_len > 0) {
                    disk_read(9, dir_buf, 1);
                    int fsector = 0;
                    int fsize   = 0;
                    int found   = dir_find(dir_buf, fname, &fsector, &fsize);
                    if (found >= 0) {
                        int sectors = (fsize / 512) + 1;
                        disk_read(fsector, text_buf, sectors);
                        text_len = fsize;
                        redraw_doc(text_buf, text_len, &cx, &cy);
                    } else {
                        // File not found — flash status
                        clear_band(188, 12);
                        draw_str(0, 189, "Not found!", 31);
                        asm("MOV RS, 7"); asm("SYS");
                        for (int t = 0; t < 30; t = t + 1) {
                            asm("MOV RS, 7"); asm("SYS");
                        }
                    }
                }
                mode = 0;

            } else {
                // ---- NEWLINE in edit mode ----
                draw_char(cx, cy, 95, 0);
                cx = 10;
                cy = cy + 12;
                text_buf[text_len] = 10;    // '\n'
                text_len = text_len + 1;
            }
            while (keys[257]) { asm("MOV RS, 7"); asm("SYS"); }
        }

        // ---- Printable character input ----
        *RC = 0;
        asm("MOV RS, 6"); asm("SYS");
        int key = *RC;

        if (key > 0) {
            if (mode == 1 || mode == 2) {
                // Type into the filename buffer
                if (fn_len < 23) {
                    fname[fn_len] = key;
                    fn_len = fn_len + 1;
                    fname[fn_len] = 0;
                }
            } else {
                // Type into the document
                draw_char(cx, cy, 95, 0);       // erase cursor
                draw_char(cx, cy, key, 255);     // draw typed char
                text_buf[text_len] = key;
                text_len = text_len + 1;
                cx = cx + 10;
                if (cx > 300) { cx = 10; cy = cy + 12; }
            }
        }
    }

    return 0;
}

// =====================================================
// DRAW_CHAR  —  8×8 bitmap font renderer
// =====================================================
void draw_char(int x, int y, int ascii, int color) {
    for (int r = 0; r < 8; r = r + 1) {
        int row_val = font[(ascii * 8) + r];
        for (int c = 0; c < 8; c = c + 1) {
            if ((row_val >> (7 - c)) & 1) {
                vram[((y + r) * 320) + (x + c)] = color;
            }
        }
    }
}

// =====================================================
// HARDWARE I/O BRIDGE
// Stack layout after ENT (args pushed left-to-right):
//   FP+8  = last arg  (count)
//   FP+12 = middle arg (dest/src pointer)
//   FP+16 = first arg (sector)
// =====================================================
void disk_read(int sector, char *dest, int count) {
    asm("LOD FP"); asm("PSH 16"); asm("ADD"); asm("PUT R3"); asm("DRP");
    asm("LDI R3"); asm("PUT RX"); asm("DRP");   // sector → RX

    asm("LOD FP"); asm("PSH 12"); asm("ADD"); asm("PUT R3"); asm("DRP");
    asm("LDI R3"); asm("PUT RY"); asm("DRP");   // dest   → RY

    asm("LOD FP"); asm("PSH 8");  asm("ADD"); asm("PUT R3"); asm("DRP");
    asm("LDI R3"); asm("PUT RC"); asm("DRP");   // count  → RC

    asm("MOV RS, DISK_READ");
    asm("SYS");
}

void disk_write(int sector, char *src, int count) {
    asm("LOD FP"); asm("PSH 16"); asm("ADD"); asm("PUT R3"); asm("DRP");
    asm("LDI R3"); asm("PUT RX"); asm("DRP");   // sector → RX

    asm("LOD FP"); asm("PSH 12"); asm("ADD"); asm("PUT R3"); asm("DRP");
    asm("LDI R3"); asm("PUT RY"); asm("DRP");   // src    → RY

    asm("LOD FP"); asm("PSH 8");  asm("ADD"); asm("PUT R3"); asm("DRP");
    asm("LDI R3"); asm("PUT RC"); asm("DRP");   // count  → RC

    asm("MOV RS, DISK_WRITE");
    asm("SYS");
}
