// =====================================================
// CURSOR_TEST.C  —  Stress test for chibicc control flow
// =====================================================

char *vram = (char *)1048576;
char *keys = (char *)2097152;

// Draw a 4x4 block to act as our cursor
void draw_cursor(int x, int y, int color) {
    for (int dy = 0; dy < 4; dy = dy + 1) {
        for (int dx = 0; dx < 4; dx = dx + 1) {
            vram[(y + dy) * 320 + (x + dx)] = color;
        }
    }
}

int main() {
    int x = 160;
    int y = 100;
    int running = 1;

    while (running) {
        // 1. Erase previous cursor position (paint black)
        draw_cursor(x, y, 0);

        // 2. Poll keyboard (Map Raylib keys: W=87, A=65, S=83, D=68, ESC=256)
        int key_pressed = 0;
        if (keys[256]) key_pressed = 256;
        else if (keys[87]) key_pressed = 87;
        else if (keys[83]) key_pressed = 83;
        else if (keys[65]) key_pressed = 65;
        else if (keys[68]) key_pressed = 68;

        // 3. TEST: Switch Statement
        switch (key_pressed) {
            case 256: 
                running = 0; 
                break;
            case 87:  y = y - 4; break; // Up
            case 83:  y = y + 4; break; // Down
            case 65:  x = x - 4; break; // Left
            case 68:  x = x + 4; break; // Right
        }

        // 4. TEST: Logical OR (||) and Ternary (? :)
        // Clamp X to screen bounds (320 width - 4 cursor width = 316)
        if (x < 0 || x > 316) {
            x = (x < 0) ? 0 : 316; 
        }

        // 5. TEST: Logical NOT (!) and Logical AND (&&)
        // Clamp Y to screen bounds (200 height - 4 cursor height = 196)
        if (!(y >= 0) && y < 200) {
            y = 0;
        } else if (y > 196) {
            y = 196;
        }

        // 6. Draw new cursor position (paint white)
        draw_cursor(x, y, 255);

        // 7. RENDER Syscall (RS = 7)
        asm("MOV RS, 7");
        asm("SYS");

        // 8. SLEEP Syscall (RS = 4, wait ~16ms for ~60fps)
        asm("MOV RX, 16");
        asm("MOV RS, 4");
        asm("SYS");
    }
    
    // EXIT Syscall (RS = 0)
    asm("MOV RS, 0");
    asm("SYS");
    return 0;
}
