; =========================================
; STANDARD C I/O LIBRARY
; Provides disk access to compiled C programs
; =========================================
.TEXT

; void disk_read(int sector, char *dest, int count);
disk_read:
    ENT
    ; Arg 1: Sector (Stored at FP + 8)
    LOD FP
    PSH 8
    ADD
    PUT R3
    DRP
    LDI R3
    PUT RX
    DRP

    ; Arg 2: Dest Buffer (Stored at FP + 12)
    LOD FP
    PSH 12
    ADD
    PUT R3
    DRP
    LDI R3
    PUT RY
    DRP

    ; Arg 3: Sector Count (Stored at FP + 16)
    LOD FP
    PSH 16
    ADD
    PUT R3
    DRP
    LDI R3
    PUT RC
    DRP

    MOV RS, 7   ; Hardware Syscall: DISK_READ
    SYS
    LEV
    RET

; void disk_write(int sector, char *src, int count);
disk_write:
    ENT
    LOD FP
    PSH 8
    ADD
    PUT R3
    DRP
    LDI R3
    PUT RX
    DRP

    LOD FP
    PSH 12
    ADD
    PUT R3
    DRP
    LDI R3
    PUT RY
    DRP

    LOD FP
    PSH 16
    ADD
    PUT R3
    DRP
    LDI R3
    PUT RC
    DRP

    MOV RS, 8   ; Hardware Syscall: DISK_WRITE
    SYS
    LEV
    RET
