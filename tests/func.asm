JMP MAIN

DOUBLE_R1:
    ENT         ; Enter frame
    LOD R1
    PSH 2
    MUL
    PUT R1      ; R1 = R1 * 2
    DRP
    LEV         ; Leave frame
    RET

MAIN:
    MOV R1, 21
    RUN DOUBLE_R1
    LOD R1
    POP         ; Should print 42
    HLT
