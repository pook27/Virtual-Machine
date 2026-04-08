.DATA
.L..7:
    2002874980
    1634231135
.L..6:
    2002874980
    1634231135
.L..1:
    1852399981
.L..0:
    1852399981
RC:
    8388376
    0
font:
    10000
    0
keys:
    2097152
    0
vram:
    1048576
    0
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
    DRP
    PSH 0
    DRP
    LOD FP
    PSH -12
    ADD
    PSH 10
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
    PSH 10
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
  MOV RS, 2
  SYS
.L.begin.1:
    PSH 1
    PUT R1
    DRP
    MOV R2, 0
    CMP R1, R2
    JIE .L..2
    LOD FP
    PSH -12
    ADD
    PUT R3
    DRP
    LDI R3
    LOD FP
    PSH -8
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 95
    PSH 255
    RUN draw_char
    DRP
    DRP
    DRP
    DRP
    LOD R1
    DRP
  MOV RS, 7
  SYS
    PSH keys
    PUT R3
    DRP
    LDI R3
    PSH 256
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
  JMP .L..2
    JMP .L.end.2
.L.else.2:
.L.end.2:
    PSH keys
    PUT R3
    DRP
    LDI R3
    PSH 257
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
    JIE .L.else.5
    LOD FP
    PSH -12
    ADD
    PUT R3
    DRP
    LDI R3
    LOD FP
    PSH -8
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 95
    PSH 0
    RUN draw_char
    DRP
    DRP
    DRP
    DRP
    LOD R1
    DRP
    LOD FP
    PSH -12
    ADD
    PSH 10
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
    LOD FP
    PSH -8
    ADD
    LOD FP
    PSH -8
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 12
    ADD
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
.L.begin.9:
    PSH keys
    PUT R3
    DRP
    LDI R3
    PSH 257
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
    JIE .L..4
  MOV RS, 7
  SYS
.L..5:
    JMP .L.begin.9
.L..4:
    JMP .L.end.5
.L.else.5:
.L.end.5:
    PSH RC
    PUT R3
    DRP
    LDI R3
    PSH 0
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
  MOV RS, 6
  SYS
    PSH 0
    DRP
    PSH 0
    DRP
    LOD FP
    PSH -4
    ADD
    PSH RC
    PUT R3
    DRP
    LDI R3
    PUT R3
    DRP
    LDI R3
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
    PSH 0
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
    JLT .L.true.13
    PSH 0
    JMP .L.end.13
.L.true.13:
    PSH 1
.L.end.13:
    PUT R1
    DRP
    MOV R2, 0
    CMP R1, R2
    JIE .L.else.12
    LOD FP
    PSH -12
    ADD
    PUT R3
    DRP
    LDI R3
    LOD FP
    PSH -8
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 95
    PSH 0
    RUN draw_char
    DRP
    DRP
    DRP
    DRP
    LOD R1
    DRP
    LOD FP
    PSH -12
    ADD
    PUT R3
    DRP
    LDI R3
    LOD FP
    PSH -8
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
    PSH 255
    RUN draw_char
    DRP
    DRP
    DRP
    DRP
    LOD R1
    DRP
    LOD FP
    PSH -12
    ADD
    LOD FP
    PSH -12
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 10
    ADD
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
    PSH 300
    LOD FP
    PSH -12
    ADD
    PUT R3
    DRP
    LDI R3
    PUT R2
    DRP
    PUT R1
    DRP
    CMP R1, R2
    JLT .L.true.16
    PSH 0
    JMP .L.end.16
.L.true.16:
    PSH 1
.L.end.16:
    PUT R1
    DRP
    MOV R2, 0
    CMP R1, R2
    JIE .L.else.15
    LOD FP
    PSH -12
    ADD
    PSH 10
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
    LOD FP
    PSH -8
    ADD
    LOD FP
    PSH -8
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 12
    ADD
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
    JMP .L.end.15
.L.else.15:
.L.end.15:
    JMP .L.end.12
.L.else.12:
.L.end.12:
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
draw_char:
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
    DRP
    PSH 0
    DRP
    LOD FP
    PSH -28
    ADD
    PSH 0
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
.L.begin.18:
    LOD FP
    PSH -28
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 8
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
    JIE .L..8
    PSH 0
    DRP
    PSH 0
    DRP
    LOD FP
    PSH -16
    ADD
    PSH font
    PUT R3
    DRP
    LDI R3
    LOD FP
    PSH 12
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 8
    MUL
    LOD FP
    PSH -28
    ADD
    PUT R3
    DRP
    LDI R3
    ADD
    PSH 1
    MUL
    ADD
    PUT R3
    DRP
    LDB R3
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
    PSH -12
    ADD
    PSH 0
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
.L.begin.24:
    LOD FP
    PSH -12
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 8
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
    JIE .L..10
    LOD FP
    PSH -16
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 7
    LOD FP
    PSH -12
    ADD
    PUT R3
    DRP
    LDI R3
    SUB
    SHR
    PSH 1
    AND
    PUT R1
    DRP
    MOV R2, 0
    CMP R1, R2
    JIE .L.else.26
    PSH vram
    PUT R3
    DRP
    LDI R3
    LOD FP
    PSH 16
    ADD
    PUT R3
    DRP
    LDI R3
    LOD FP
    PSH -28
    ADD
    PUT R3
    DRP
    LDI R3
    ADD
    PSH 320
    MUL
    LOD FP
    PSH 20
    ADD
    PUT R3
    DRP
    LDI R3
    LOD FP
    PSH -12
    ADD
    PUT R3
    DRP
    LDI R3
    ADD
    ADD
    PSH 1
    MUL
    ADD
    LOD FP
    PSH 8
    ADD
    PUT R3
    DRP
    LDI R3
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STB R3
    DRP
    JMP .L.end.26
.L.else.26:
.L.end.26:
.L..11:
    LOD FP
    PSH -8
    ADD
    LOD FP
    PSH -12
    ADD
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
    LOD FP
    PSH -8
    ADD
    PUT R3
    DRP
    LDI R3
    LOD FP
    PSH -8
    ADD
    PUT R3
    DRP
    LDI R3
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
    PSH -1
    ADD
    DRP
    JMP .L.begin.24
.L..10:
.L..9:
    LOD FP
    PSH -24
    ADD
    LOD FP
    PSH -28
    ADD
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
    LOD FP
    PSH -24
    ADD
    PUT R3
    DRP
    LDI R3
    LOD FP
    PSH -24
    ADD
    PUT R3
    DRP
    LDI R3
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
    PSH -1
    ADD
    DRP
    JMP .L.begin.18
.L..8:
.L.return.draw_char:
    LEV
    RET
