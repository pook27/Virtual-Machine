; =============================================================
; PALETTE VIEWER
; Renders all 256 palette colours as a 16x16 grid.
; Each cell is 20px wide x 12px tall.
; Run standalone:  ./build.sh palette
; =============================================================

.DEFINE VRAM      1048576
.DEFINE VRAM_W    320
.DEFINE CELL_W    20
.DEFINE CELL_H    12

.DATA
COLOR_IDX: 0        ; current palette index (0-255)
CELL_COL:  0        ; column in the grid (0-15)
CELL_ROW:  0        ; row in the grid (0-15)
PX:        0        ; pixel column within the cell
PY:        0        ; pixel row within the cell
ADDR:      0        ; scratch: computed VRAM address

.TEXT
    ; Clear the screen then draw every colour
    MOV RS, CLEAR
    SYS

    MOV COLOR_IDX, 0
    MOV CELL_ROW, 0

; ---- Outer loop: row 0-15 ----
OUTER_ROW:
    MOV R0, 16
    CMP CELL_ROW, R0
    JIE DRAW_DONE

    MOV CELL_COL, 0

; ---- Mid loop: column 0-15 ----
OUTER_COL:
    MOV R0, 16
    CMP CELL_COL, R0
    JIE NEXT_ROW

    ; ---- Inner loops: fill one CELL_W x CELL_H cell ----
    MOV PY, 0

FILL_Y:
    MOV R0, CELL_H
    CMP PY, R0
    JIE CELL_DONE

    MOV PX, 0

FILL_X:
    MOV R0, CELL_W
    CMP PX, R0
    JIE FILL_X_END

    ; addr = VRAM + (CELL_ROW*CELL_H + PY) * VRAM_W + (CELL_COL*CELL_W + PX)
    LOD CELL_ROW
    PSH CELL_H
    MUL
    LOD PY
    ADD
    PSH VRAM_W
    MUL             ; (row_y) * 320
    LOD CELL_COL
    PSH CELL_W
    MUL
    LOD PX
    ADD             ; col_x
    ADD             ; row_y*320 + col_x
    PSH VRAM
    ADD
    PUT ADDR
    DRP

    LOD COLOR_IDX
    STB ADDR
    DRP

    ; PX++
    LOD PX
    PSH 1
    ADD
    PUT PX
    DRP
    JMP FILL_X

FILL_X_END:
    ; PY++
    LOD PY
    PSH 1
    ADD
    PUT PY
    DRP
    JMP FILL_Y

CELL_DONE:
    ; Advance to next colour and column
    LOD COLOR_IDX
    PSH 1
    ADD
    PUT COLOR_IDX
    DRP

    LOD CELL_COL
    PSH 1
    ADD
    PUT CELL_COL
    DRP
    JMP OUTER_COL

NEXT_ROW:
    LOD CELL_ROW
    PSH 1
    ADD
    PUT CELL_ROW
    DRP
    JMP OUTER_ROW

DRAW_DONE:
    ; Flush once, then loop keeping the window alive
    MOV RS, RENDER
    SYS
    JMP DRAW_DONE
