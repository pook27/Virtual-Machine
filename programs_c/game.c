int main() {
    // Hardware Memory Maps
    char *vram = (char *)1048576;
    char *keys = (char *)2097152;
    
    int x = 160;
    int y = 100;
    
    while (1) {
        // 1. Clear Screen (Syscall 2)
        asm("MOV RS, 2"); 
        asm("SYS");
        
        // 2. Hardware Input (Non-blocking MMIO!)
        if (keys[87]) y = y - 1; // W
        if (keys[83]) y = y + 1; // S
        if (keys[65]) x = x - 1; // A
        if (keys[68]) x = x + 1; // D
        
        // 3. Screen Bounds Collision
        if (x < 0) x = 0;
        if (x > 319) x = 319;
        if (y < 0) y = 0;
        if (y > 199) y = 199;
        
        // 4. Direct VRAM Rendering
        vram[(y * 320) + x] = 42; // Cyan pixel
        
        // 5. Render to Monitor (Syscall 7)
        asm("MOV RS, 7"); 
        asm("SYS");
        
        // 6. Frame Pacing: Sleep for 16ms (~60 FPS) (Syscall 4)
        asm("MOV RS, 4"); 
        asm("MOV RX, 16"); 
        asm("SYS");
    }
    
    return 0;
}
