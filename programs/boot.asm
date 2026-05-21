; BOOT.ASM - Sector 0
    MOV RS, DISK_READ
    MOV RX, 1
    MOV RY, 4096
    MOV RC, 63      ; Read 63 sectors (32KB) instead of 20
    SYS
    JMP 4096
