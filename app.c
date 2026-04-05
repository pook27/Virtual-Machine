int player_x = 10;
int player_y = 100;
int velocity_x = 1;

void main() {
    while(1) {
        sys_clear();
        
        // Draw a green pixel! (Color 40)
        draw_pixel(player_x, player_y, 40);
        
        sys_render();
        
        player_x = player_x + velocity_x;
    }
}
