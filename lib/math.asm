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
    RUN NEGATE 
ABS_DONE:
    LEV
    RET

; MIN: R1 = min(R1, R2), result in R1
MIN:
    ENT
    CMP R1, R2
    JLT MIN_DONE    ; R1 < R2, R1 is already the min
    JIE MIN_DONE    ; R1 == R2, doesn't matter
    LOD R2          ; R1 > R2, so R2 is the min
    PUT R1
    DRP
MIN_DONE:
    LEV
    RET

; MAX: R1 = max(R1, R2), result in R1
MAX:
    ENT
    CMP R1, R2
    JGT MAX_DONE    ; R1 > R2, R1 is already the max
    JIE MAX_DONE    ; R1 == R2, doesn't matter
    LOD R2          ; R1 < R2, so R2 is the max
    PUT R1
    DRP
MAX_DONE:
    LEV
    RET


; POW: R1 = R1 ^ R2  (integer exponentiation, R2 >= 0)
; uses R3 as loop counter, R4 as accumulator
POW:
    ENT
    MOV R4, 1       ; accumulator = 1
    MOV R3, 0       ; R3 = loop counter starting at 0
POW_LOOP:
    CMP R3, R2      ; if counter == exponent, done
    JIE POW_DONE
    LOD R4          ; accumulator = accumulator * R1
    LOD R1
    MUL
    PUT R4
    DRP
    LOD R3          ; counter++
    PSH 1
    ADD
    PUT R3
    DRP
    JMP POW_LOOP
POW_DONE:
    LOD R4
    PUT R1          ; result in R1
    DRP
    LEV
    RET

; SIGN: R1 = sign of R1 (-1, 0, or 1)
SIGN:
    ENT
    MOV R2, 0
    CMP R1, R2
    JIE SIGN_ZERO
    JGT SIGN_POS
    PSH -1          ; negative
    PUT R1
    DRP
    JMP SIGN_DONE
SIGN_POS:
    PSH 1
    PUT R1
    DRP
    JMP SIGN_DONE
SIGN_ZERO:
    PSH 0
    PUT R1
    DRP
SIGN_DONE:
    LEV
    RET
