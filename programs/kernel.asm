; -----------------------------------------
; SECTOR 1: THE OS KERNEL (THE SHELL)
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

; The Shell Cursor
CURSOR_X: 20
CURSOR_Y: 20

.TEXT
JMP OS_MAIN

; -----------------------------------------
; SUBROUTINE: DRAW_CHAR
; R1 = X, R2 = Y, R3 = ASCII Char, R4 = Color
; -----------------------------------------
DRAW_CHAR:
    LOD R3
    PSH 8
    MUL
    PSH FONT_RAM
    ADD
    PUT CHAR_PTR
    DRP

    MOV ROW_CNT, 0
CHAR_ROW_LOOP:
    MOV R0, 8
    CMP ROW_CNT, R0
    JIE CHAR_END

    LOD CHAR_PTR
    LOD ROW_CNT
    ADD
    PUT R0          
    DRP
    
    LDB R0
    PUT ROW_VAL
    DRP

    MOV COL_CNT, 0
CHAR_COL_LOOP:
    MOV R0, 8
    CMP COL_CNT, R0
    JIE CHAR_COL_END

    LOD ROW_VAL
    PSH 7
    LOD COL_CNT
    SUB
    SHR             
    PSH 1
    AND             
    PUT R0
    DRP

    MOV RS, 1
    CMP R0, RS
    JIE DRAW_PIXEL
    JMP SKIP_PIXEL

DRAW_PIXEL:
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

    LOD R4
    STB R0
    DRP

SKIP_PIXEL:
    LOD COL_CNT
    PSH 1
    ADD
    PUT COL_CNT
    DRP
    JMP CHAR_COL_LOOP

CHAR_COL_END:
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
    ; 1. Clear Screen & Load File System
    MOV RS, CLEAR
    SYS
    MOV RS, DISK_READ
    MOV RX, 9
    MOV RY, DIR_RAM
    MOV RC, 1
    SYS

    ; 2. Load font.bin (Sector 10)
    MOV RS, DISK_READ
    MOV RX, 10
    MOV RY, FONT_RAM
    MOV RC, 4       
    SYS

    ; 3. Draw the Command Line Prompt ">" (ASCII 62)
    MOV R1, 10
    MOV R2, 20
    MOV R3, 62
    MOV R4, 42      ; Cyan color for the prompt
    RUN DRAW_CHAR

; -----------------------------------------
; THE TYPEWRITER LOOP
; -----------------------------------------
TYPEWRITER:
    ; A. Clear RC before we poll for input (crucial!)
    MOV RC, 0
    
    ; B. Ask Hardware for a keystroke
    MOV RS, INPUT
    SYS

    ; C. If RC is 0, no key was pressed. Skip to rendering!
    MOV R0, 0
    CMP RC, R0
    JIE RENDER_FRAME

    ; D. A KEY WAS PRESSED! Draw it!
    LOD CURSOR_X
    PUT R1
    DRP

    LOD CURSOR_Y
    PUT R2
    DRP

    LOD RC          ; RC holds the ASCII value of the key pressed!
    PUT R3
    DRP

    MOV R4, 115     ; Sky blue text
    RUN DRAW_CHAR

    ; E. Advance the Cursor 10 pixels to the right
    LOD CURSOR_X
    PSH 10
    ADD
    PUT CURSOR_X
    DRP

RENDER_FRAME:
    MOV RS, RENDER
    SYS
    JMP TYPEWRITER
