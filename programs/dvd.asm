; -----------------------------------------
; SECTOR 1: THE ANIMATION KERNEL
; Bouncing Box (DVD Screensaver Style)
; -----------------------------------------
.DEFINE VRAM 1048576 

; --- VARIABLE RAM ---
.DATA
POS_X: 160
POS_Y: 100
VEL_X: 2
VEL_Y: 2
COLOR: 42   ; Start with Cyan

.TEXT
JMP OS_MAIN

; -----------------------------------------
; SUBROUTINE: DRAW_BOX (10x10)
; -----------------------------------------
DRAW_BOX:
    MOV R1, 0       ; row counter (y)
BOX_Y:
    MOV R0, 10
    CMP R1, R0
    JIE BOX_END

    MOV R2, 0       ; col counter (x)
BOX_X:
    MOV R0, 10
    CMP R2, R0
    JIE BOX_X_END

    ; Target Address = VRAM + (POS_Y + R1) * 320 + (POS_X + R2)
    LOD POS_Y       ; Push Y position
    LOD R1          ; <--- FIXED: LOD reads the value of R1!
    ADD
    PSH 320         ; Multiply by Screen Width
    MUL
    LOD POS_X       ; Add X position
    ADD
    LOD R2          ; <--- FIXED: LOD reads the value of R2!
    ADD
    PSH VRAM        ; Add Base VRAM address
    ADD
    PUT R3          ; Store final address pointer in R3
    DRP             ; Clean stack

    LOD COLOR       ; Push the color byte
    STB R3          ; Write color byte to the memory address stored in R3
    DRP

    ; col++
    LOD R2
    PSH 1
    ADD
    PUT R2
    DRP
    JMP BOX_X

BOX_X_END:
    ; row++
    LOD R1
    PSH 1
    ADD
    PUT R1
    DRP
    JMP BOX_Y

BOX_END:
    RET

; -----------------------------------------
; MAIN OS LOOP
; -----------------------------------------
OS_MAIN:

MAIN_LOOP:
    ; 1. Wipe the screen black instantly via C Syscall
    MOV RS, CLEAR
    SYS

    ; 2. Call the drawing subroutine
    RUN DRAW_BOX

    ; 3. Blast the VRAM to the monitor
    MOV RS, RENDER
    SYS

    ; 4. Update X Position (POS_X = POS_X + VEL_X)
    LOD POS_X
    LOD VEL_X
    ADD
    PUT POS_X
    PUT R1      ; Also copy new POS_X to R1 for boundary checking
    DRP

    ; Check Left Bound (POS_X <= 0)
    MOV R2, 0
    CMP R1, R2
    JLT BOUNCE_X
    JIE BOUNCE_X

    ; Check Right Bound (POS_X >= 310) [320 screen width - 10 box width]
    MOV R2, 310
    CMP R1, R2
    JGT BOUNCE_X
    JIE BOUNCE_X
    JMP UPDATE_Y

BOUNCE_X:
    ; Reverse X Velocity (VEL_X = 0 - VEL_X)
    PSH 0
    LOD VEL_X
    SUB
    PUT VEL_X
    DRP

    ; Shift the Color!
    LOD COLOR
    PSH 13
    ADD
    PUT COLOR
    DRP

UPDATE_Y:
    ; 5. Update Y Position (POS_Y = POS_Y + VEL_Y)
    LOD POS_Y
    LOD VEL_Y
    ADD
    PUT POS_Y
    PUT R1      ; Copy to R1 for bounds check
    DRP

    ; Check Top Bound (POS_Y <= 0)
    MOV R2, 0
    CMP R1, R2
    JLT BOUNCE_Y
    JIE BOUNCE_Y

    ; Check Bottom Bound (POS_Y >= 190) [200 screen height - 10 box height]
    MOV R2, 190
    CMP R1, R2
    JGT BOUNCE_Y
    JIE BOUNCE_Y
    JMP MAIN_LOOP

BOUNCE_Y:
    ; Reverse Y Velocity (VEL_Y = 0 - VEL_Y)
    PSH 0
    LOD VEL_Y
    SUB
    PUT VEL_Y
    DRP

    ; Shift the Color!
    LOD COLOR
    PSH 13
    ADD
    PUT COLOR
    DRP

    JMP MAIN_LOOP
