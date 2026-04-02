#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#define SECTOR_SIZE 512

void write32_to_file(FILE *f, int val) {
    uint8_t bytes[4];
    bytes[0] = val & 0xFF;
    bytes[1] = (val >> 8) & 0xFF;
    bytes[2] = (val >> 16) & 0xFF;
    bytes[3] = (val >> 24) & 0xFF;
    fwrite(bytes, 1, 4, f);
}

int main(int argc, char* argv[]) {
    if (argc < 3) {
        printf("Usage: %s <output.img> <file1.img> [file2.img ...]\n", argv[0]);
        return 1;
    }
    
    FILE* img = fopen(argv[1], "wb");
    if (!img) return 1;
    // Loop through all input .vm files and pack them into sectors
    for (int i = 2; i < argc; i++) {
        FILE* vm = fopen(argv[i], "r");
        if (!vm) {
            printf("Could not open %s\n", argv[i]);
            continue;
        }

        printf("Writing %s to image...\n", argv[i]);
        char line[32];
        int bytes_written = 0;

        while (fgets(line, sizeof(line), vm)) {
            int val = atoi(line);
            write32_to_file(img, val);
            bytes_written += 4;
        }
        fclose(vm);

        // Pad the remainder of the sector with 0s so the next file starts cleanly!
        int padding = SECTOR_SIZE - (bytes_written % SECTOR_SIZE);
        if (padding != SECTOR_SIZE) {
            for (int p = 0; p < padding; p++) fputc(0, img);
        }
    }

    // Pad the rest of the file to create a full 1 Megabyte Hard Drive
    long current_size = ftell(img);
    long target_size = 1024 * 1024; // 1 MB
    while (current_size < target_size) {
        fputc(0, img);
        current_size++;
    }

    fclose(img);
    printf("Successfully built Hard Drive: %s\n", argv[1]);
    return 0;
}
