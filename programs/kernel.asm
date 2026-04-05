; -----------------------------------------
; SECTOR 1: THE OS KERNEL
; Virtual File System Loader
; -----------------------------------------
.DEFINE DIR_RAM 8192      ; Load Directory Table here
.DEFINE USER_RAM 20000    ; Load games into this safe "User Space"
.DEFINE DIR_SECTOR 9      ; Sector 9 is our Directory

JMP OS_MAIN

OS_MAIN:
    ; 1. Clear the screen while we load
    MOV RS, CLEAR
    SYS
    MOV RS, RENDER
    SYS

    ; 2. Load the Directory Table (Sector 9) into RAM at address 8192
    MOV RS, DISK_READ
    MOV RX, DIR_SECTOR
    MOV RY, DIR_RAM
    MOV RC, 1           ; Read exactly 1 Sector (512 bytes)
    SYS

    ; 3. Parse the Start Sector of the first file (dvd.bin)
    ; In our 32-byte Directory Entry, Bytes 0-23 are the Name,
    ; and Byte 24 is the Start Sector!
    PSH DIR_RAM
    PSH 24
    ADD
    PUT R2      ; R2 now holds the memory address: 8192 + 24 = 8216
    DRP

    LDB [R2]    ; Read the byte at address 8216!
    PUT RX      ; R3 now perfectly holds '10' (The Start Sector!)
    DRP

    ; 4. Load the Game from the Disk into User Space!
    MOV RS, DISK_READ
    MOV RY, USER_RAM    ; Dest: Safe User Space (RAM 20000)
    MOV RC, 5           ; Load 5 Sectors (2.5 KB) just to be safe
    SYS

    ; 5. Hand control over to the loaded game!
    RUN USER_RAM

IDLE:
    ; If the game ever exits, the OS just hangs out here.
    JMP IDLE
