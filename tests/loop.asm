; Loop from 3 down to 1, printing the counter
MOV R1, 3

LOOP:
    LOD R1
    POP         ; Print counter

    ; Decrement R1
    LOD R1
    PSH 1
    SUB
    PUT R1
    DRP

    ; Check if > 0
    MOV R2, 0
    CMP R1, R2
    JGT LOOP    ; Jump if R1 > R2

HLT
