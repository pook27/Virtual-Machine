.DATA
.L..1:
    1852399981
.L..0:
    1852399981
player_y:
    100
player_x:
    160
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
  MOV RS, 2
  SYS
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
.L.begin.1:
    LOD FP
    PSH -12
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 50
    PUT R2
    DRP
    PUT R1
    DRP
    CMP R1, R2
    JLT .L.true.2
    PSH 0
    JMP .L.end.2
.L.true.2:
    PSH 1
.L.end.2:
    PUT R1
    DRP
    MOV R2, 0
    CMP R1, R2
    JIE .L..2
    LOD FP
    PSH -24
    ADD
    PUT R3
    DRP
    LDI R3
    PSH player_y
    PUT R3
    DRP
    LDI R3
    PSH 320
    MUL
    PSH player_x
    PUT R3
    DRP
    LDI R3
    ADD
    LOD FP
    PSH -12
    ADD
    PUT R3
    DRP
    LDI R3
    ADD
    PSH 4
    MUL
    ADD
    PSH 42
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
.L..3:
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
    JMP .L.begin.1
.L..2:
  MOV RS, 7
  SYS
    PSH 0
    PUT R1
    DRP
    JMP .L.return.main
    PSH 0
.L.return.main:
    LEV
    RET
