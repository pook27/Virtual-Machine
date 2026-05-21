int player_x = 160;
int player_y = 100;

int main() {
    // 1. Clear the screen (Syscall 2)
    asm("MOV RS, 2");
    asm("SYS");

    // 2. Direct VRAM Access using Pointers!
    // VRAM is an array of integers starting at 1048576
    int *vram = (char *)1048576;
    
    // Draw a horizontal line using a C loop!
    for (int i = 0; i < 50; i++) {
        // address = y * 320 + x + i
        vram[(player_y * 320) + player_x + i] = 42; // 42 is Cyan
    }

    // 3. Render to screen (Syscall 7)
    asm("MOV RS, 7");
    asm("SYS");
    
    return 0;
}
