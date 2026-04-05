#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "vm.h"

int main(int argc, char* argv[]) {
    if (argc < 3) {
        printf("Usage: %s <output.img> <file1.bin> [file2.bin ...]\n", argv[0]);
        return 1;
    }

    FILE* img = fopen(argv[1], "wb");
    if (!img) return 1;

    for (int i = 2; i < argc; i++) {
        FILE* bin = fopen(argv[i], "rb");
        if (!bin) continue;

        printf("Writing %s to image...\n", argv[i]);
        uint8_t byte;
        int bytes_written = 0;

        // Directly copy compiled bytes to the hard drive
        while (fread(&byte, 1, 1, bin)) {
            fputc(byte, img);
            bytes_written++;
        }
        fclose(bin);

        // Pad to exactly 512 bytes (1 Sector)
        int padding = SECTOR_SIZE - (bytes_written % SECTOR_SIZE);
        if (padding != SECTOR_SIZE) {
            for (int p = 0; p < padding; p++) fputc(0, img);
        }
    }

    // Pad to 1 Megabyte
    long current_size = ftell(img);
    long target_size = 1024 * 1024;
    while (current_size < target_size) {
        fputc(0, img);
        current_size++;
    }

    fclose(img);
    return 0;
}
