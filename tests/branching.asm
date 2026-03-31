; Compare -5 to 0
MOV R1, -5
MOV R2, 0

CMP R1, R2
JLT IS_NEGATIVE     ; -5 < 0, so it SHOULD jump
JMP FAILED          ; If it doesn't jump, fail

IS_NEGATIVE:
    LOD R1
    POP             ; Print -5
    JMP DONE

FAILED:
    PSH 999
    POP

DONE:
    HLT
