; =============================================================
; STARFIELD SCREENSAVER
; Three parallax layers of stars scroll left at different speeds.
; Stars wrap to the right edge on exit and get a new Y position.
;
; Memory layout (star data lives in high addresses, clear of code):
;   FAR  layer: 20 stars × 8 bytes at address 25000
;   MID  layer: 15 stars × 8 bytes at address 25200
;   NEAR layer: 10 stars × 8 bytes at address 25400
;
; Run standalone:  ./build.sh starfield
; =============================================================

.DEFINE VRAM       1048576
.DEFINE VRAM_W     320
.DEFINE VRAM_H     200

; Star array base addresses (above any code the assembler will produce)
.DEFINE FAR_BASE   25000
.DEFINE FAR_CNT    20
.DEFINE MID_BASE   25200
.DEFINE MID_CNT    15
.DEFINE NEAR_BASE  25400
.DEFINE NEAR_CNT   10

; Palette colour indices for each layer
.DEFINE COL_FAR    73       ; dim blue-grey
.DEFINE COL_MID    182      ; medium white
.DEFINE COL_NEAR   255      ; bright white

; ---- Subroutine parameters (passed via DATA vars) ----
.DATA
LAYER_BASE:   0
LAYER_CNT:    0
LAYER_COL:    0
LAYER_SPD:    0
; Subroutine scratch
L_PTR:        0
L_END:        0
STAR_X:       0
STAR_Y:       0
; Init scratch
INIT_X_STEP:  0
INIT_X_OFF:   0
INIT_Y_MUL:   0
INIT_Y_OFF:   0
IDX:          0

.TEXT

; ---- Initialise all three layers ----

    MOV LAYER_BASE,  FAR_BASE
    MOV LAYER_CNT,   FAR_CNT
    MOV INIT_X_STEP, 16
    MOV INIT_X_OFF,  0
    MOV INIT_Y_MUL,  7
    MOV INIT_Y_OFF,  3
    RUN INIT_LAYER

    MOV LAYER_BASE,  MID_BASE
    MOV LAYER_CNT,   MID_CNT
    MOV INIT_X_STEP, 21
    MOV INIT_X_OFF,  10
    MOV INIT_Y_MUL,  11
    MOV INIT_Y_OFF,  50
    RUN INIT_LAYER

    MOV LAYER_BASE,  NEAR_BASE
    MOV LAYER_CNT,   NEAR_CNT
    MOV INIT_X_STEP, 32
    MOV INIT_X_OFF,  5
    MOV INIT_Y_MUL,  17
    MOV INIT_Y_OFF,  100
    RUN INIT_LAYER

; ---- Main animation loop ----
MAIN_LOOP:
    MOV RS, CLEAR
    SYS

    MOV LAYER_BASE, FAR_BASE
    MOV LAYER_CNT,  FAR_CNT
    MOV LAYER_COL,  COL_FAR
    MOV LAYER_SPD,  1
    RUN PROCESS_LAYER

    MOV LAYER_BASE, MID_BASE
    MOV LAYER_CNT,  MID_CNT
    MOV LAYER_COL,  COL_MID
    MOV LAYER_SPD,  2
    RUN PROCESS_LAYER

    MOV LAYER_BASE, NEAR_BASE
    MOV LAYER_CNT,  NEAR_CNT
    MOV LAYER_COL,  COL_NEAR
    MOV LAYER_SPD,  3
    RUN PROCESS_LAYER

    MOV RS, RENDER
    SYS

    JMP MAIN_LOOP

; =============================================================
; SUBROUTINE: INIT_LAYER
; Spreads stars deterministically across the screen.
; Params: LAYER_BASE, LAYER_CNT, INIT_X_STEP, INIT_X_OFF,
;         INIT_Y_MUL, INIT_Y_OFF
; =============================================================
INIT_LAYER:
    MOV IDX, 0
    LOD LAYER_BASE
    PUT L_PTR
    DRP

INIT_LOOP:
    CMP IDX, LAYER_CNT
    JIE INIT_DONE

    ; x = (IDX * INIT_X_STEP + INIT_X_OFF) % VRAM_W
    LOD IDX
    LOD INIT_X_STEP
    MUL
    LOD INIT_X_OFF
    ADD
    PSH VRAM_W
    MOD
    PUT STAR_X
    DRP

    ; y = (IDX * INIT_Y_MUL + INIT_Y_OFF) % VRAM_H
    LOD IDX
    LOD INIT_Y_MUL
    MUL
    LOD INIT_Y_OFF
    ADD
    PSH VRAM_H
    MOD
    PUT STAR_Y
    DRP

    ; Write x to memory[L_PTR]
    LOD STAR_X
    STI L_PTR
    DRP

    ; Write y to memory[L_PTR + 4]
    LOD L_PTR
    PSH 4
    ADD
    PUT R0
    DRP
    LOD STAR_Y
    STI R0
    DRP

    ; L_PTR += 8  (advance to next star)
    LOD L_PTR
    PSH 8
    ADD
    PUT L_PTR
    DRP

    ; IDX++
    LOD IDX
    PSH 1
    ADD
    PUT IDX
    DRP
    JMP INIT_LOOP

INIT_DONE:
    RET

; =============================================================
; SUBROUTINE: PROCESS_LAYER
; Draws each star in the layer then moves it left by LAYER_SPD.
; Wraps stars that leave the left edge back to x=319 with a new y.
; Params: LAYER_BASE, LAYER_CNT, LAYER_COL, LAYER_SPD
; =============================================================
PROCESS_LAYER:
    ; L_END = LAYER_BASE + LAYER_CNT * 8
    LOD LAYER_CNT
    PSH 8
    MUL
    LOD LAYER_BASE
    ADD
    PUT L_END
    DRP

    LOD LAYER_BASE
    PUT L_PTR
    DRP

PROC_LOOP:
    CMP L_PTR, L_END
    JIE PROC_DONE

    ; -- Load star x and y --
    LDI L_PTR
    PUT STAR_X
    DRP

    LOD L_PTR
    PSH 4
    ADD
    PUT R0
    DRP
    LDI R0
    PUT STAR_Y
    DRP

    ; -- Draw pixel at (STAR_X, STAR_Y) --
    LOD STAR_Y
    PSH VRAM_W
    MUL
    LOD STAR_X
    ADD
    PSH VRAM
    ADD
    PUT R0
    DRP
    LOD LAYER_COL
    STB R0
    DRP

    ; -- Move left: STAR_X -= LAYER_SPD --
    LOD STAR_X
    LOD LAYER_SPD
    SUB
    PUT STAR_X
    DRP

    ; -- Wrap if STAR_X < 0 --
    MOV R1, 0
    CMP STAR_X, R1
    JLT WRAP_STAR
    JMP STAR_DONE

WRAP_STAR:
    ; Reset to right edge
    PSH 319
    PUT STAR_X
    DRP

    ; New y: (STAR_Y * 13 + 47) % VRAM_H   (simple hash, stays positive)
    LOD STAR_Y
    PSH 13
    MUL
    PSH 47
    ADD
    PSH VRAM_H
    MOD
    PUT STAR_Y
    DRP

STAR_DONE:
    ; -- Write updated x back to memory[L_PTR] --
    LOD STAR_X
    STI L_PTR
    DRP

    ; -- Write updated y back to memory[L_PTR + 4] --
    LOD L_PTR
    PSH 4
    ADD
    PUT R0
    DRP
    LOD STAR_Y
    STI R0
    DRP

    ; -- Advance pointer to next star --
    LOD L_PTR
    PSH 8
    ADD
    PUT L_PTR
    DRP

    JMP PROC_LOOP

PROC_DONE:
    RET
