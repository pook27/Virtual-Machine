; Initialize our loop counter
MOV R0, 3

MAIN_LOOP:
    ; Set up the argument for our subroutine (e.g., let's square the number 4)
    MOV R1, 4

    ; Call the subroutine
    RUN SQUARE

    ; Print the result
    MOV RS, 1       ; Syscall 1
    LOD R1
    POP             ; Will print 16

    ; Decrement loop counter
    LOD R0
    PSH 1
    SUB
    PUT R0
    DRP

    ; Check if counter is still greater than 0
    MOV R2, 0       ; Dummy register to hold 0
    CMP R0, R2      ; Compare R0 and R2
    JGT MAIN_LOOP   ; If R0 > 0, loop again!

    ; Exit cleanly
    HLT

; =========================================
; SUBROUTINE: SQUARE
; Multiplies R1 by itself, saves back in R1
; =========================================
SQUARE:
    LOD R1
    LOD R1
    MUL
    PUT R1
    DRP
    RET             ; Returns back to MAIN_LOOP
