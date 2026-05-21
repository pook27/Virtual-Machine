// ==========================================
// WOLF-3D ENGINE (Pure Integer Fixed-Point)
// ==========================================

char *vram = (char *)1048576;
char *keys = (char *)2097152;

// 8x8 Map (1 = Wall, 0 = Empty Space)
int map[64] = {
    1,1,1,1,1,1,1,1,
    1,0,0,0,0,0,0,1,
    1,0,1,0,0,1,0,1,
    1,0,1,0,0,0,0,1,
    1,0,0,0,0,1,0,1,
    1,0,1,1,0,1,0,1,
    1,0,0,0,0,0,0,1,
    1,1,1,1,1,1,1,1
};

// 90 Degrees of Sine (Scaled by 256)
int sin90[91] = {
    0, 4, 8, 13, 17, 22, 26, 31, 35, 40, 44, 48, 53, 57, 61, 65, 70, 74, 78, 83, 87, 
    91, 95, 99, 103, 107, 111, 115, 119, 123, 128, 131, 135, 139, 143, 146, 150, 153, 
    157, 160, 164, 167, 171, 174, 177, 181, 184, 187, 190, 193, 196, 198, 201, 204, 
    206, 209, 211, 213, 216, 218, 220, 222, 224, 226, 228, 229, 231, 232, 234, 235, 
    237, 238, 239, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 250, 251, 252, 
    253, 253, 254, 254, 255
};

int cos_table[360];
int sin_table[360];

void init_tables() {
    // Generate the full 360-degree tables by mirroring the 90-degree slice!
    for (int i = 0; i < 360; i++) {
        int s = 0; int c = 0;
        if (i < 90) { s = sin90[i]; c = sin90[90-i]; }
        else if (i < 180) { s = sin90[180-i]; c = -sin90[i-90]; }
        else if (i < 270) { s = -sin90[i-180]; c = -sin90[270-i]; }
        else { s = -sin90[360-i]; c = sin90[i-270]; }
        sin_table[i] = s;
        cos_table[i] = c;
    }
}

// Player State
int p_x = 100;   // Player X (Start at block 4,4 scaled up)
int p_y = 100;   // Player Y
int p_angle = 0; // Player looking angle (0-359)

int main() {
    init_tables();

    while (1) {
        // 1. ROTATION (A / D)
        if (keys[65]) p_angle = p_angle - 4; 
        if (keys[68]) p_angle = p_angle + 4; 
        if (p_angle < 0) p_angle = p_angle + 360;
        if (p_angle > 359) p_angle = p_angle - 360;

        // 2. MOVEMENT (W / S)
        int dx = (cos_table[p_angle] * 6) / 256;
        int dy = (sin_table[p_angle] * 6) / 256;

        if (keys[87]) { p_x = p_x + dx; p_y = p_y + dy; }
        if (keys[83]) { p_x = p_x - dx; p_y = p_y - dy; }

        // Wall Collision (Bounce back if we step into a wall block)
        if (map[((p_y / 64) * 8) + (p_x / 64)] > 0) {
            if (keys[87]) { p_x = p_x - dx; p_y = p_y - dy; }
            if (keys[83]) { p_x = p_x + dx; p_y = p_y + dy; }
        }

        // 3. RAYCASTING LOOP (Draw 64 columns, 5px wide each = 320px)
        for (int i = 0; i < 64; i++) {
            // Sweep the camera angle from -32 to +32 degrees
            int ray_angle = p_angle - 32 + i;
            if (ray_angle < 0) ray_angle = ray_angle + 360;
            if (ray_angle > 359) ray_angle = ray_angle - 360;

            int rx = p_x * 256; 
            int ry = p_y * 256;
            int step_x = cos_table[ray_angle];
            int step_y = sin_table[ray_angle];
            int distance = 1; // Start at 1 to prevent divide-by-zero
            int hit = 0;

            // Step the ray forward until it hits a wall
            while (hit == 0) {
                rx = rx + step_x;
                ry = ry + step_y;
                distance = distance + 1;

                int map_x = (rx / 256) / 64;
                int map_y = (ry / 256) / 64;

                // Prevent going completely off the 8x8 map
                if (map_x < 0) map_x = 0; if (map_x > 7) map_x = 7;
                if (map_y < 0) map_y = 0; if (map_y > 7) map_y = 7;

                if (map[(map_y * 8) + map_x] > 0) hit = 1;
                if (distance > 1000) hit = 1; 
            }

            // Fix "Fish-eye" distortion
            int diff = ray_angle - p_angle;
            if (diff < 0) diff = diff + 360;
            if (diff > 359) diff = diff - 360;
            distance = (distance * cos_table[diff]) / 256;
            if (distance < 1) distance = 1;

            // Calculate Wall Height
            int wall_height = 8000 / distance; 
            if (wall_height > 200) wall_height = 200;

            int start_y = 100 - (wall_height / 2);
            int end_y = 100 + (wall_height / 2);

            // Draw a 5-pixel wide rectangle for this ray
            for (int w = 0; w < 5; w++) {
                int screen_x = (i * 5) + w;

                // Start at the very top of the screen for this column
                int vram_idx = screen_x;

                for (int y = 0; y < 200; y++) {
                    if (y < start_y) vram[vram_idx] = 0;       // Black ceiling
                    else if (y < end_y) vram[vram_idx] = 31;   // Cyan Wall
                    else vram[vram_idx] = 146;                 // Grey Floor

                    // Jump down exactly one row in VRAM! (No multiplication needed!)
                    vram_idx = vram_idx + 320;
                } 
            }
        }

        asm("MOV RS, 7"); // Render Frame
        asm("SYS");
    }
    return 0;
}
