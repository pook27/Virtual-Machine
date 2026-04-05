; -----------------------------------------
; SECTOR 1: THE OS MICROKERNEL
; -----------------------------------------
.DEFINE DIR_RAM 8192
.DEFINE FONT_RAM 10000    
.DEFINE VRAM 1048576 
.DEFINE VRAM_WIDTH 320
.DEFINE KEYBOARD 2097152
.DEFINE KEY_ENTER 257
.DEFINE USER_RAM 20000
.DEFINE CMD_BUFFER 50000 

.DATA
CHAR_PTR: 0
ROW_CNT: 0
COL_CNT: 0
ROW_VAL: 0
CURSOR_X: 20
CURSOR_Y: 20
CMD_LEN: 0

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
    MOV RS, CLEAR
    SYS
    MOV RS, DISK_READ
    MOV RX, 9
    MOV RY, DIR_RAM
    MOV RC, 1
    SYS

    PSH 8216
    PUT R0
    DRP
    LDB R0      
    PUT RX
    DRP
    MOV RS, DISK_READ
    MOV RY, FONT_RAM
    MOV RC, 4       
    SYS

    JMP DRAW_PROMPT

; -----------------------------------------
; THE HARDWARE EVENT LOOP
; -----------------------------------------
TYPEWRITER:
    MOV RS, RENDER
    SYS

    PSH KEYBOARD
    PSH KEY_ENTER
    ADD
    PUT R0
    DRP
    LDB R0
    PUT R1
    DRP
    MOV R2, 1
    CMP R1, R2
    JIE EXECUTE

    MOV RC, 0
    MOV RS, INPUT
    SYS

    MOV R0, 0
    CMP RC, R0
    JIE TYPEWRITER

    LOD CMD_LEN
    PSH CMD_BUFFER
    ADD
    PUT R0
    DRP
    LOD RC
    STB R0      
    DRP

    LOD CURSOR_X
    PUT R1
    DRP
    LOD CURSOR_Y
    PUT R2
    DRP
    LOD RC
    PUT R3
    DRP
    MOV R4, 115 
    RUN DRAW_CHAR

    LOD CURSOR_X
    PSH 10
    ADD
    PUT CURSOR_X
    DRP
    LOD CMD_LEN
    PSH 1
    ADD
    PUT CMD_LEN
    DRP
    JMP TYPEWRITER

; -----------------------------------------
; COMMAND HANDOFF
; -----------------------------------------
EXECUTE:
WAIT_ENTER:
    MOV RS, RENDER
    SYS
    PSH KEYBOARD
    PSH KEY_ENTER
    ADD
    PUT R0
    DRP
    LDB R0
    PUT R1
    DRP
    MOV R2, 1
    CMP R1, R2
    JIE WAIT_ENTER

    MOV R0, 0
    CMP CMD_LEN, R0
    JIE NEW_LINE

    ; Memory[CMD_BUFFER + CMD_LEN] = \0
    LOD CMD_LEN
    PSH CMD_BUFFER
    ADD
    PUT R0
    DRP
    PSH 0
    STB R0
    DRP

    ; HAND OVER TO THE SHELL LIBRARY!
    RUN PROCESS_COMMAND

NEW_LINE:
    LOD CURSOR_Y
    PSH 12
    ADD
    PUT CURSOR_Y
    DRP
    MOV CMD_LEN, 0

DRAW_PROMPT:
    MOV CURSOR_X, 10
    LOD CURSOR_X
    PUT R1
    DRP
    LOD CURSOR_Y
    PUT R2
    DRP
    MOV R3, 62  
    MOV R4, 42  
    RUN DRAW_CHAR
    MOV CURSOR_X, 20
    JMP TYPEWRITER

; =========================================
; LOAD EXTERNAL OS LIBRARIES
; =========================================
%include "lib/shell.asm"
