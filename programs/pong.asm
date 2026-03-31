; -----------------------------
; --- GAME STATE (DATA) -------
; -----------------------------
.DATA
    ; Ball Physics
    ball_x: 10
    ball_y: 5
    ball_vx: 1      ; Velocity X (1 = moving right, -1 = moving left)
    ball_vy: 1      ; Velocity Y (1 = moving up, -1 = moving left)
    
    ; Paddle State (X is fixed at 2)
    paddle_y: 5

; -----------------------------
; --- MAIN GAME LOOP ----------
; -----------------------------
.TEXT
MAIN:
    ; --- 1. HANDLE INPUT ---
    MOV RS, INPUT
    SYS
    
    ; Check if 'w' (ASCII 119) was pressed
    MOV R2, 119
    CMP RC, R2
    JIE MOVE_UP
    
    ; Check if 's' (ASCII 115) was pressed
    MOV R2, 115
    CMP RC, R2
    JIE MOVE_DOWN
    
    JMP UPDATE_PHYSICS ; If no valid key, skip movement

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
    ; --- 2. MOVE BALL ---
    ; ball_x = ball_x + ball_vx
    LOD ball_x
    LOD ball_vx
    ADD
    PUT ball_x
    DRP
    
    ; ball_y = ball_y + ball_vy
    LOD ball_y
    LOD ball_vy
    ADD
    PUT ball_y
    DRP

    ; --- 3. WALL COLLISIONS ---
    ; Top Wall (Y <= 1)
    MOV R2, 1
    CMP ball_y, R2
    JLT BOUNCE_Y
    JIE BOUNCE_Y
    
    ; Bottom Wall (Y >= 20)
    MOV R2, 20
    CMP ball_y, R2
    JGT BOUNCE_Y
    JIE BOUNCE_Y
    
    JMP CHECK_X_WALLS

BOUNCE_Y:
    LOD ball_vy
    PUT R1
    DRP
    RUN NEGATE          ; R1 = R1 * -1
    LOD R1
    PUT ball_vy
    DRP

CHECK_X_WALLS:
    ; Right Wall (X >= 40)
    MOV R2, 40
    CMP ball_x, R2
    JGT BOUNCE_X
    JIE BOUNCE_X

    ; Left Wall / Paddle logic (X <= 2)
    MOV R2, 2
    CMP ball_x, R2
    JLT CHECK_PADDLE
    JIE CHECK_PADDLE
    
    JMP RENDER

CHECK_PADDLE:
    ; Did the ball hit the paddle's Y coordinate?
    LOD ball_y
    PUT R1
    DRP
    LOD paddle_y
    PUT R2
    DRP
    CMP R1, R2
    JIE BOUNCE_X        ; It's a hit! Bounce it!
    
    ; If we missed the paddle, reset the ball to the center
    MOV R2, 20
    PUT ball_x
    JMP RENDER

BOUNCE_X:
    LOD ball_vx
    PUT R1
    DRP
    RUN NEGATE          ; R1 = R1 * -1
    LOD R1
    PUT ball_vx
    DRP

RENDER:
    ; --- 4. DRAW TO SCREEN ---
    MOV RS, CLEAR
    SYS
    
    ; Draw Paddle (at fixed X=2, Y=paddle_y)
    MOV RS, DRAW
    MOV RX, 2
    LOD paddle_y
    PUT RY
    DRP
    SYS
    
    ; Draw Ball (at X=ball_x, Y=ball_y)
    MOV RS, DRAW
    LOD ball_x
    PUT RX
    DRP
    LOD ball_y
    PUT RY
    DRP
    SYS
    
    ; --- 5. SLEEP & LOOP ---
    MOV RS, SLEEP
    MOV RX, 60          ; 60ms delay per frame (~16 FPS)
    SYS
    
    JMP MAIN

    HLT

%include lib/math.asm
