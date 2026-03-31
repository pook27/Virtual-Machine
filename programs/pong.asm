.DEFINE C_RED 31
.DEFINE C_GREEN 32
.DEFINE C_YELLOW 33
.DEFINE C_BLUE 34
.DEFINE C_MAGENTA 35
.DEFINE C_CYAN 36
.DEFINE C_WHITE 37

.DATA
    ball_x: 32      ; Start center of 64 width
    ball_y: 15      ; Start center of 32 height
    ball_vx: 1      
    ball_vy: 1      
    paddle_y: 15
    wall_y: 31      ; Updated to VRAM height
    wall_x: 63      ; Updated to VRAM width

.TEXT
MAIN:
    MOV RC, 0
    MOV RS, INPUT
    SYS
    
    MOV R2, 119
    CMP RC, R2
    JIE MOVE_UP
    
    MOV R2, 115
    CMP RC, R2
    JIE MOVE_DOWN
    
    JMP UPDATE_PHYSICS

MOVE_UP:
    LOD paddle_y
    PSH 1
    SUB
    PUT paddle_y
    DRP
    JMP UPDATE_PHYSICS

MOVE_DOWN:
    LOD paddle_y
    PSH 1
    ADD
    PUT paddle_y
    DRP
    JMP UPDATE_PHYSICS

UPDATE_PHYSICS:
    LOD ball_x
    LOD ball_vx
    ADD
    PUT ball_x
    DRP
    
    LOD ball_y
    LOD ball_vy
    ADD
    PUT ball_y
    DRP

    ; Top Wall
    MOV R2, 1
    CMP ball_y, R2
    JLT BOUNCE_Y
    JIE BOUNCE_Y
    
    ; Bottom Wall
    CMP ball_y, wall_y
    JGT BOUNCE_Y
    JIE BOUNCE_Y
    
    JMP CHECK_X_WALLS

BOUNCE_Y:
    LOD ball_vy
    PUT R1
    DRP
    RUN NEGATE
    LOD R1
    PUT ball_vy
    DRP

CHECK_X_WALLS:
    CMP ball_x, wall_x
    JGT BOUNCE_X
    JIE BOUNCE_X

    MOV R2, 2
    CMP ball_x, R2
    JLT CHECK_PADDLE
    JIE CHECK_PADDLE
    
    JMP DRAW_FRAME

CHECK_PADDLE:
    LOD ball_y
    PUT R1
    DRP

    LOD paddle_y
    PSH 1
    SUB
    PUT R2
    DRP
    CMP R1, R2
    JLT PADDLE_MISS

    LOD paddle_y
    PSH 1
    ADD
    PUT R2
    DRP
    CMP R1, R2
    JGT PADDLE_MISS

    JMP BOUNCE_X

PADDLE_MISS:
    PSH 32          ; Respawn center
    PUT ball_x
    DRP
    PSH 15
    PUT ball_y
    DRP
    PSH -1          ; Serve left
    PUT ball_vx
    DRP
    JMP DRAW_FRAME

BOUNCE_X:
    LOD ball_vx
    PUT R1
    DRP
    RUN NEGATE
    LOD R1
    PUT ball_vx
    DRP

DRAW_FRAME:
    ; Wipe VRAM clean before we draw the new frame
    MOV RS, CLEAR
    SYS
    
    ; Draw Paddle Top
    MOV R3, C_CYAN
    MOV RX, 2
    LOD paddle_y
    PSH 1
    SUB
    PUT RY
    DRP
    RUN DRAW_PIXEL

    ; Draw Paddle Middle
    MOV RX, 2
    LOD paddle_y
    PUT RY
    DRP
    RUN DRAW_PIXEL

    ; Draw Paddle Bottom
    MOV RX, 2
    LOD paddle_y
    PSH 1
    ADD
    PUT RY
    DRP
    RUN DRAW_PIXEL

    ; Draw Ball
    MOV R3, C_RED
    LOD ball_x
    PUT RX
    DRP
    LOD ball_y
    PUT RY
    DRP
    RUN DRAW_PIXEL

    ; ---> FLUSH VRAM TO SCREEN! <---
    MOV RS, RENDER
    SYS

    MOV RS, SLEEP
    MOV RX, 30      ; Sleep 30ms (~33 FPS)
    SYS
    
    JMP MAIN
    HLT

; =========================================
; SUBROUTINE: DRAW_PIXEL
; Takes RX (X coord) and RY (Y coord)
; Maps them to VRAM and writes a 1
; =========================================
DRAW_PIXEL:
    ENT
    ; Formula: 4096 + (RY * 64) + RX
    LOD RY
    PSH 64
    MUL             ; RY * 64
    LOD RX
    ADD             ; + RX
    PSH 4096
    ADD             ; + 4096 (VRAM BASE)
    PUT R1          ; Store pointer in R1
    DRP
    
    LOD R3          ; Load The Color From R3
    PUT [R1]        ; Store The Color into VRAM memory address!
    DRP
    LEV
    RET

%include lib/math.asm
