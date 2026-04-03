; -----------------------------------------
; SECTOR 1: THE OPERATING SYSTEM SHELL
; -----------------------------------------
.DEFINE SYS_CLEAR 2
.DEFINE SYS_RENDER 7
.DEFINE SYS_DRAW_TEXT 10

; Colors
.DEFINE C_WHITE 37
.DEFINE C_CYAN 36
.DEFINE C_YELLOW 33

JMP OS_MAIN

STR_TITLE:
    .STRING "VIRTUAL MACHINE OS v1.0"
STR_SUBTITLE:
    .STRING "System Memory: 8 MB OK"
STR_PROMPT:
    .STRING "> Waiting for input..."

OS_MAIN:
    ; 1. Clear the screen to black
    MOV RS, SYS_CLEAR
    SYS

    ; 2. Render the empty VRAM background
    MOV RS, SYS_RENDER
    SYS

    ; 3. Draw Title (Size 20, Cyan)
    MOV RS, SYS_DRAW_TEXT
    MOV RC, STR_TITLE
    MOV RX, 20      ; X pos
    MOV RY, 20      ; Y pos
    MOV R1, 20      ; Font Size
    MOV R2, C_CYAN  ; Color
    SYS

    ; 4. Draw Subtitle (Size 10, White)
    MOV RS, SYS_DRAW_TEXT
    MOV RC, STR_SUBTITLE
    MOV RX, 20
    MOV RY, 50
    MOV R1, 10
    MOV R2, C_WHITE
    SYS

    ; 5. Draw Prompt (Size 10, Yellow)
    MOV RS, SYS_DRAW_TEXT
    MOV RC, STR_PROMPT
    MOV RX, 20
    MOV RY, 80
    MOV R1, 10
    MOV R2, C_YELLOW
    SYS

IDLE:
    ; The OS idles here waiting for you to type
    JMP IDLE
