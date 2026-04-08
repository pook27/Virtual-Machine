#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#include "vm.h"

#define BOOT_SECTOR    0
#define KERNEL_SECTOR  1
#define DIR_SECTOR     9
#define DATA_SECTOR    10

void write32(FILE* f, uint32_t val) {
    uint8_t bytes[4];
    bytes[0] = val & 0xFF;
    bytes[1] = (val >> 8) & 0xFF;
    bytes[2] = (val >> 16) & 0xFF;
    bytes[3] = (val >> 24) & 0xFF;
    fwrite(bytes, 1, 4, f);
}

void pad_to_sector(FILE* f, int bytes_written) {
    int padding = SECTOR_SIZE - (bytes_written % SECTOR_SIZE);
    if (padding != SECTOR_SIZE) {
        for (int p = 0; p < padding; p++) fputc(0, f);
    }
}

const char* get_filename(const char* path) {
    const char* slash = strrchr(path, '/');
    return slash ? slash + 1 : path;
}

int main(int argc, char* argv[]) {
    if (argc < 4) {
        printf("Usage: %s <output.img> <boot.bin> <kernel.bin> [file1.bin ...]\n", argv[0]);
        return 1;
    }

    FILE* img = fopen(argv[1], "wb");
    if (!img) return 1;

    printf("Flashing Bootloader: %s\n", argv[2]);
    FILE* boot = fopen(argv[2], "rb");
    int bytes = 0; uint8_t b;
    while (fread(&b, 1, 1, boot)) { fputc(b, img); bytes++; }
    fclose(boot);
    pad_to_sector(img, bytes);

    printf("Flashing OS Kernel: %s\n", argv[3]);
    FILE* kernel = fopen(argv[3], "rb");
    bytes = 0;
    while (fread(&b, 1, 1, kernel)) { fputc(b, img); bytes++; }
    fclose(kernel);
    pad_to_sector(img, bytes);
    
    long current_pos = ftell(img);
    long dir_pos = DIR_SECTOR * SECTOR_SIZE;
    while (current_pos < dir_pos) { fputc(0, img); current_pos++; }

    
    uint8_t directory[SECTOR_SIZE] = {0};
    int dir_offset = 0;
    int current_file_sector = DATA_SECTOR;

    fseek(img, DATA_SECTOR * SECTOR_SIZE, SEEK_SET);

    for (int i = 4; i < argc; i++) {
        FILE* file = fopen(argv[i], "rb");
        if (!file) continue;

        const char* name = get_filename(argv[i]);
        char clean_name[24] = {0};
        strncpy(clean_name, name, 23);
        char* dot = strrchr(clean_name, '.');
        if (dot) *dot = '\0';

        printf("Installing File: %s (Sector %d)\n", clean_name, current_file_sector);
        strncpy((char*)&directory[dir_offset], clean_name, 23);

        int file_size = 0;
        while (fread(&b, 1, 1, file)) { fputc(b, img); file_size++; }
        fclose(file);
        pad_to_sector(img, file_size);

        directory[dir_offset + 24] = current_file_sector & 0xFF;
        directory[dir_offset + 25] = (current_file_sector >> 8) & 0xFF;
        directory[dir_offset + 26] = (current_file_sector >> 16) & 0xFF;
        directory[dir_offset + 27] = (current_file_sector >> 24) & 0xFF;

        directory[dir_offset + 28] = file_size & 0xFF;
        directory[dir_offset + 29] = (file_size >> 8) & 0xFF;
        directory[dir_offset + 30] = (file_size >> 16) & 0xFF;
        directory[dir_offset + 31] = (file_size >> 24) & 0xFF;

        dir_offset += 32;
        current_file_sector += (file_size / SECTOR_SIZE) + ((file_size % SECTOR_SIZE) ? 1 : 0);
    }

    fseek(img, DIR_SECTOR * SECTOR_SIZE, SEEK_SET);
    fwrite(directory, 1, SECTOR_SIZE, img);

    fseek(img, 0, SEEK_END);
    current_pos = ftell(img);
    long target_size = 1024 * 1024;
    while (current_pos < target_size) { fputc(0, img); current_pos++; }

    fclose(img);
    printf("Successfully built VFS Hard Drive: %s\n", argv[1]);
    return 0;
}
