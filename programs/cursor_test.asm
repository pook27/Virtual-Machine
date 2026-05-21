.DATA
.L..7:
    1852399981
.L..6:
    1852399981
.L..1:
    2002874980
    1920295775
    7499635
.L..0:
    2002874980
    1920295775
    7499635
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
    PSH -16
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
    PSH -12
    ADD
    PSH 100
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
    PSH 1
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
.L.begin.1:
    LOD FP
    PSH -8
    ADD
    PUT R3
    DRP
    LDI R3
    PUT R1
    DRP
    MOV R2, 0
    CMP R1, R2
    JIE .L..8
    LOD FP
    PSH -16
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
    PSH 0
    RUN draw_cursor
    DRP
    DRP
    DRP
    LOD R1
    DRP
    PSH 0
    DRP
    PSH 0
    DRP
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
    LOD FP
    PSH -4
    ADD
    PSH 256
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
    JMP .L.end.2
.L.else.2:
    PSH keys
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
    JIE .L.else.5
    LOD FP
    PSH -4
    ADD
    PSH 87
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
    JMP .L.end.5
.L.else.5:
    PSH keys
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
    JIE .L.else.8
    LOD FP
    PSH -4
    ADD
    PSH 83
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
    JMP .L.end.8
.L.else.8:
    PSH keys
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
    JIE .L.else.11
    LOD FP
    PSH -4
    ADD
    PSH 65
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
    JMP .L.end.11
.L.else.11:
    PSH keys
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
    PSH -4
    ADD
    PSH 68
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
.L.end.11:
.L.end.8:
.L.end.5:
.L.end.2:
    LOD FP
    PSH -4
    ADD
    PUT R3
    DRP
    LDI R3
    PUT R1
    DRP
    MOV R2, 68
    CMP R1, R2
    JIE .L..15
    MOV R2, 65
    CMP R1, R2
    JIE .L..14
    MOV R2, 83
    CMP R1, R2
    JIE .L..13
    MOV R2, 87
    CMP R1, R2
    JIE .L..12
    MOV R2, 256
    CMP R1, R2
    JIE .L..11
    JMP .L..10
.L..11:
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
  JMP .L..10
.L..12:
    LOD FP
    PSH -12
    ADD
    LOD FP
    PSH -12
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 4
    SUB
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
  JMP .L..10
.L..13:
    LOD FP
    PSH -12
    ADD
    LOD FP
    PSH -12
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 4
    ADD
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
  JMP .L..10
.L..14:
    LOD FP
    PSH -16
    ADD
    LOD FP
    PSH -16
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 4
    SUB
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
  JMP .L..10
.L..15:
    LOD FP
    PSH -16
    ADD
    LOD FP
    PSH -16
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 4
    ADD
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
  JMP .L..10
.L..10:
    LOD FP
    PSH -16
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
    JGT .L.true.22
    JLT .L.true.22
    PSH 316
    LOD FP
    PSH -16
    ADD
    PUT R3
    DRP
    LDI R3
    PUT R2
    DRP
    PUT R1
    DRP
    CMP R1, R2
    JLT .L.true.24
    PSH 0
    JMP .L.end.24
.L.true.24:
    PSH 1
.L.end.24:
    PUT R1
    DRP
    MOV R2, 0
    CMP R1, R2
    JGT .L.true.22
    JLT .L.true.22
    PSH 0
    JMP .L.end.22
.L.true.22:
    PSH 1
.L.end.22:
    PUT R1
    DRP
    MOV R2, 0
    CMP R1, R2
    JIE .L.else.21
    LOD FP
    PSH -16
    ADD
    LOD FP
    PSH -16
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
    JLT .L.true.26
    PSH 0
    JMP .L.end.26
.L.true.26:
    PSH 1
.L.end.26:
    PUT R1
    DRP
    MOV R2, 0
    CMP R1, R2
    JIE .L.else.25
    PSH 0
    JMP .L.end.25
.L.else.25:
    PSH 316
.L.end.25:
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
    JMP .L.end.21
.L.else.21:
.L.end.21:
    PSH 0
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
    JLT .L.true.30
    JIE .L.true.30
    PSH 0
    JMP .L.end.30
.L.true.30:
    PSH 1
.L.end.30:
    PUT R1
    DRP
    MOV R2, 0
    CMP R1, R2
    JIE .L.true.29
    PSH 0
    JMP .L.end.29
.L.true.29:
    PSH 1
.L.end.29:
    PUT R1
    DRP
    MOV R2, 0
    CMP R1, R2
    JIE .L.false.28
    LOD FP
    PSH -12
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 200
    PUT R2
    DRP
    PUT R1
    DRP
    CMP R1, R2
    JLT .L.true.31
    PSH 0
    JMP .L.end.31
.L.true.31:
    PSH 1
.L.end.31:
    PUT R1
    DRP
    MOV R2, 0
    CMP R1, R2
    JIE .L.false.28
    PSH 1
    JMP .L.end.28
.L.false.28:
    PSH 0
.L.end.28:
    PUT R1
    DRP
    MOV R2, 0
    CMP R1, R2
    JIE .L.else.27
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
    JMP .L.end.27
.L.else.27:
    PSH 196
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
    JLT .L.true.33
    PSH 0
    JMP .L.end.33
.L.true.33:
    PSH 1
.L.end.33:
    PUT R1
    DRP
    MOV R2, 0
    CMP R1, R2
    JIE .L.else.32
    LOD FP
    PSH -12
    ADD
    PSH 196
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
    JMP .L.end.32
.L.else.32:
.L.end.32:
.L.end.27:
    LOD FP
    PSH -16
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
    PSH 255
    RUN draw_cursor
    DRP
    DRP
    DRP
    LOD R1
    DRP
  MOV RS, 7
  SYS
  MOV RX, 16
  MOV RS, 4
  SYS
.L..9:
    JMP .L.begin.1
.L..8:
  MOV RS, 0
  SYS
    PSH 0
    PUT R1
    DRP
    JMP .L.return.main
    PSH 0
.L.return.main:
    LEV
    RET
draw_cursor:
    ENT
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    DRP
    PSH 0
    DRP
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
.L.begin.34:
    LOD FP
    PSH -8
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 4
    PUT R2
    DRP
    PUT R1
    DRP
    CMP R1, R2
    JLT .L.true.35
    PSH 0
    JMP .L.end.35
.L.true.35:
    PSH 1
.L.end.35:
    PUT R1
    DRP
    MOV R2, 0
    CMP R1, R2
    JIE .L..2
    PSH 0
    DRP
    PSH 0
    DRP
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
.L.begin.36:
    LOD FP
    PSH -4
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 4
    PUT R2
    DRP
    PUT R1
    DRP
    CMP R1, R2
    JLT .L.true.37
    PSH 0
    JMP .L.end.37
.L.true.37:
    PSH 1
.L.end.37:
    PUT R1
    DRP
    MOV R2, 0
    CMP R1, R2
    JIE .L..4
    PSH vram
    PUT R3
    DRP
    LDI R3
    LOD FP
    PSH 12
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
    ADD
    PSH 320
    MUL
    LOD FP
    PSH 16
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
.L..5:
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
    JMP .L.begin.36
.L..4:
.L..3:
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
    JMP .L.begin.34
.L..2:
.L.return.draw_cursor:
    LEV
    RET
