.DATA
.L..1:
    1852399981
.L..0:
    1852399981
.TEXT
main:
    ENT
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    DRP
    PSH 0
    DRP
    PSH 0
    DRP
    LOD FP
    PSH -24
    ADD
    PSH 1048576
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
    PSH 0
    DRP
    PSH 0
    DRP
    PSH 0
    DRP
    LOD FP
    PSH -16
    ADD
    PSH 2097152
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
    PSH 0
    DRP
    PSH 0
    DRP
    LOD FP
    PSH -8
    ADD
    PSH 160
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
    PSH 0
    DRP
    PSH 0
    DRP
    LOD FP
    PSH -4
    ADD
    PSH 100
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
.L.begin.1:
    PSH 1
    PUT R1
    DRP
    MOV R2, 0
    CMP R1, R2
    JIE .L..2
  MOV RS, 2
  SYS
    LOD FP
    PSH -16
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 87
    PSH 1
    MUL
    ADD
    PUT R3
    DRP
    LDB R3
    PUT R1
    DRP
    MOV R2, 0
    CMP R1, R2
    JIE .L.else.2
    LOD FP
    PSH -4
    ADD
    LOD FP
    PSH -4
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 1
    SUB
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
    JMP .L.end.2
.L.else.2:
.L.end.2:
    LOD FP
    PSH -16
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 83
    PSH 1
    MUL
    ADD
    PUT R3
    DRP
    LDB R3
    PUT R1
    DRP
    MOV R2, 0
    CMP R1, R2
    JIE .L.else.6
    LOD FP
    PSH -4
    ADD
    LOD FP
    PSH -4
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 1
    ADD
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
    JMP .L.end.6
.L.else.6:
.L.end.6:
    LOD FP
    PSH -16
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 65
    PSH 1
    MUL
    ADD
    PUT R3
    DRP
    LDB R3
    PUT R1
    DRP
    MOV R2, 0
    CMP R1, R2
    JIE .L.else.10
    LOD FP
    PSH -8
    ADD
    LOD FP
    PSH -8
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 1
    SUB
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
    JMP .L.end.10
.L.else.10:
.L.end.10:
    LOD FP
    PSH -16
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 68
    PSH 1
    MUL
    ADD
    PUT R3
    DRP
    LDB R3
    PUT R1
    DRP
    MOV R2, 0
    CMP R1, R2
    JIE .L.else.14
    LOD FP
    PSH -8
    ADD
    LOD FP
    PSH -8
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 1
    ADD
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
    JMP .L.end.14
.L.else.14:
.L.end.14:
    LOD FP
    PSH -8
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 0
    PUT R2
    DRP
    PUT R1
    DRP
    CMP R1, R2
    JLT .L.true.19
    PSH 0
    JMP .L.end.19
.L.true.19:
    PSH 1
.L.end.19:
    PUT R1
    DRP
    MOV R2, 0
    CMP R1, R2
    JIE .L.else.18
    LOD FP
    PSH -8
    ADD
    PSH 0
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
    JMP .L.end.18
.L.else.18:
.L.end.18:
    PSH 319
    LOD FP
    PSH -8
    ADD
    PUT R3
    DRP
    LDI R3
    PUT R2
    DRP
    PUT R1
    DRP
    CMP R1, R2
    JLT .L.true.21
    PSH 0
    JMP .L.end.21
.L.true.21:
    PSH 1
.L.end.21:
    PUT R1
    DRP
    MOV R2, 0
    CMP R1, R2
    JIE .L.else.20
    LOD FP
    PSH -8
    ADD
    PSH 319
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
    JMP .L.end.20
.L.else.20:
.L.end.20:
    LOD FP
    PSH -4
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 0
    PUT R2
    DRP
    PUT R1
    DRP
    CMP R1, R2
    JLT .L.true.23
    PSH 0
    JMP .L.end.23
.L.true.23:
    PSH 1
.L.end.23:
    PUT R1
    DRP
    MOV R2, 0
    CMP R1, R2
    JIE .L.else.22
    LOD FP
    PSH -4
    ADD
    PSH 0
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
    JMP .L.end.22
.L.else.22:
.L.end.22:
    PSH 199
    LOD FP
    PSH -4
    ADD
    PUT R3
    DRP
    LDI R3
    PUT R2
    DRP
    PUT R1
    DRP
    CMP R1, R2
    JLT .L.true.25
    PSH 0
    JMP .L.end.25
.L.true.25:
    PSH 1
.L.end.25:
    PUT R1
    DRP
    MOV R2, 0
    CMP R1, R2
    JIE .L.else.24
    LOD FP
    PSH -4
    ADD
    PSH 199
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
    JMP .L.end.24
.L.else.24:
.L.end.24:
    LOD FP
    PSH -24
    ADD
    PUT R3
    DRP
    LDI R3
    LOD FP
    PSH -4
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 320
    MUL
    LOD FP
    PSH -8
    ADD
    PUT R3
    DRP
    LDI R3
    ADD
    PSH 1
    MUL
    ADD
    PSH 42
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STB R3
    DRP
  MOV RS, 7
  SYS
  MOV RS, 4
  MOV RX, 16
  SYS
.L..3:
    JMP .L.begin.1
.L..2:
    PSH 0
    PUT R1
    DRP
    JMP .L.return.main
    PSH 0
.L.return.main:
    LEV
    RET
