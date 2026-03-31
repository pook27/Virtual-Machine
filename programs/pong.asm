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

    ; Walls coordinates
    wall_y: 20
    wall_x: 50

; -----------------------------
; --- MAIN GAME LOOP ----------
; -----------------------------
.TEXT
MAIN:
    ; Clear last input
    MOV RC, 0

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
    
    ; Bottom Wall (Y >= wall_y)
    CMP ball_y, wall_y
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
    ; Right Wall (X >= wall_x)
    CMP ball_x, wall_x
    JGT BOUNCE_X
    JIE BOUNCE_X

    ; Left Wall / Paddle logic (X <= 2)
    MOV R2, 2
    CMP ball_x, R2
    JLT CHECK_PADDLE
    JIE CHECK_PADDLE
    
    JMP RENDER

CHECK_PADDLE:
    LOD ball_y
    PUT R1
    DRP

    ; Check ball_y >= paddle_y - 1
    LOD paddle_y
    PSH 1
    SUB
    PUT R2
    DRP
    CMP R1, R2
    JLT PADDLE_MISS     ; ball above paddle top, miss

    ; Check ball_y <= paddle_y + 1
    LOD paddle_y
    PSH 1
    ADD
    PUT R2
    DRP
    CMP R1, R2
    JGT PADDLE_MISS     ; ball below paddle bottom, miss

    JMP BOUNCE_X        ; within range, it's a hit!

PADDLE_MISS:
    ; 1. Respawn ball in the middle of the board (X = 25)
    PSH 25
    PUT ball_x
    DRP
    
    ; 2. Respawn ball in the middle of the Y axis (Y = 10)
    PSH 10
    PUT ball_y
    DRP
    
    ; 3. Serve the ball LEFT towards the player (Velocity = -1)
    PSH -1
    PUT ball_vx
    DRP
    
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
    
    ; Draw Paddle (3 pixels tall, at fixed X=2)
    MOV RS, DRAW
    MOV RX, 2
    LOD paddle_y        ; Top pixel: paddle_y - 1
    PSH 1
    SUB
    PUT RY
    DRP
    SYS

    MOV RS, DRAW
    MOV RX, 2
    LOD paddle_y        ; Middle pixel: paddle_y
    PUT RY
    DRP
    SYS

    MOV RS, DRAW
    MOV RX, 2
    LOD paddle_y        ; Bottom pixel: paddle_y + 1
    PSH 1
    ADD
    PUT RY
    DRP
    SYS

    ; Draw Ball          <-- THIS WAS MISSING
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
    MOV RX, 60
    SYS
    
    JMP MAIN
    HLT

%include lib/math.asm
