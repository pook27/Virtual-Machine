; -----------------------------------------
; SECTOR 1: THE OS KERNEL (VGA FONT BLITTER)
; -----------------------------------------
.DEFINE DIR_RAM 8192
.DEFINE FONT_RAM 10000    
.DEFINE VRAM 1048576 
.DEFINE VRAM_WIDTH 320

; --- MEMORY VARIABLES ---
.DATA
CHAR_PTR: 0
ROW_CNT: 0
COL_CNT: 0
ROW_VAL: 0

.TEXT
JMP OS_MAIN

; -----------------------------------------
; SUBROUTINE: DRAW_CHAR
; R1 = X, R2 = Y, R3 = ASCII Char, R4 = Color
; -----------------------------------------
DRAW_CHAR:
    ; 1. Calculate Sprite Memory Address = FONT_RAM + (Char * 8)
    LOD R3
    PSH 8
    MUL
    PSH FONT_RAM
    ADD
    PUT CHAR_PTR
    DRP

    MOV ROW_CNT, 0  ; Initialize row counter to 0
CHAR_ROW_LOOP:
    MOV R0, 8
    CMP ROW_CNT, R0
    JIE CHAR_END

    ; 2. Load the 8-bit Sprite Row
    LOD CHAR_PTR
    LOD ROW_CNT
    ADD
    PUT R0          
    DRP
    
    LDB R0          ; Read the 8 pixels
    PUT ROW_VAL     ; Store sprite byte
    DRP

    MOV COL_CNT, 0  ; Initialize col counter to 0
CHAR_COL_LOOP:
    MOV R0, 8
    CMP COL_CNT, R0
    JIE CHAR_COL_END

    ; 3. Bitwise Magic: Check if pixel is 1
    LOD ROW_VAL
    PSH 7
    LOD COL_CNT
    SUB
    SHR             
    PSH 1
    AND             
    PUT R0
    DRP

    ; If bit is 0, skip drawing
    MOV RS, 1       ; Use RS as a temp register to hold 1
    CMP R0, RS
    JIE DRAW_PIXEL
    JMP SKIP_PIXEL

DRAW_PIXEL:
    ; 4. Calculate VRAM Address = VRAM + (Y + ROW_CNT) * 320 + (X + COL_CNT)
    LOD R2
    LOD ROW_CNT
    ADD
    PSH VRAM_WIDTH
    MUL
    LOD R1
    ADD
    LOD COL_CNT
    ADD
    PSH VRAM
    ADD
    PUT R0
    DRP

    ; 5. Blast the Color to VRAM
    LOD R4
    STB R0
    DRP

SKIP_PIXEL:
    ; col_counter++
    LOD COL_CNT
    PSH 1
    ADD
    PUT COL_CNT
    DRP
    JMP CHAR_COL_LOOP

CHAR_COL_END:
    ; row_counter++
    LOD ROW_CNT
    PSH 1
    ADD
    PUT ROW_CNT
    DRP
    JMP CHAR_ROW_LOOP

CHAR_END:
    RET

; -----------------------------------------
; MAIN OS BOOT
; -----------------------------------------
OS_MAIN:
    ; 1. Clear Screen
    MOV RS, CLEAR
    SYS

    ; 2. Load the Directory (Sector 9)
    MOV RS, DISK_READ
    MOV RX, 9
    MOV RY, DIR_RAM
    MOV RC, 1
    SYS

    ; 3. Load font.bin (Sector 10)
    MOV RS, DISK_READ
    MOV RX, 10
    MOV RY, FONT_RAM
    MOV RC, 4       
    SYS

    ; 4. Print "OS" using our custom Software Blitter!
    MOV R1, 150     ; X = 150
    MOV R2, 90      ; Y = 90
    MOV R3, 79      ; ASCII 79 = 'O'
    MOV R4, 115     ; Color = Sky Blue
    RUN DRAW_CHAR

    MOV R1, 160     ; X = 160 (Shift right by 10 pixels)
    MOV R2, 90      ; Y = 90
    MOV R3, 83      ; ASCII 83 = 'S'
    MOV R4, 115     ; Color = Sky Blue
    RUN DRAW_CHAR

IDLE:
    MOV RS, RENDER
    SYS
    JMP IDLE
