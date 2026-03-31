; -----------------------------------------
; MATH LIBRARY
; -----------------------------------------

; Reverses the sign of R1 (R1 = R1 * -1)
NEGATE:
    ENT
    LOD R1
    PSH -1
    MUL
    PUT R1
    DRP
    LEV
    RET

; Converts R1 to its absolute value
ABS:
    ENT
    MOV R2, 0
    CMP R1, R2
    JGT ABS_DONE ; If R1 > 0, we are already positive, jump to end
    JIE ABS_DONE ; If R1 == 0, jump to end
    ; If we didn't jump, it's negative. So negate it!
    CAL NEGATE 
ABS_DONE:
    LEV
    RET
