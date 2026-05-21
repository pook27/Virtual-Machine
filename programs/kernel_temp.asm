.DATA
.L..22:
    45
.L..19:
    1701602643
    1629516899
    1869770784
    1835102823
.L..18:
    1414747459
    1327517007
    1162551379
    1279610450
.L..17:
    1852399981
.L..16:
    1852399981
.L..13:
    2002874980
    1920234335
    6778473
.L..12:
    2002874980
    1920234335
    6778473
.L..7:
    2002874980
    1634231135
.L..6:
    2002874980
    1634231135
.L..5:
    1684956530
.L..4:
    1684956530
.L..3:
    1802725732
    1634038367
.L..2:
    1802725732
    1634038367
.L..1:
    1601135711
    1802725732
    1634038367
.L..0:
    1601135711
    1802725732
    1634038367
sys_rc:
    0
sys_ry:
    0
sys_rx:
    0
font:
    100000
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
    PSH vram
    PUT R3
    DRP
    LDI R3
    PSH 0
    PSH 1
    MUL
    ADD
    PSH 200
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STB R3
    DRP
    RUN render
    LOD R1
    DRP
    PSH 65
    PSH font
    PUT R3
    DRP
    LDI R3
    PSH 4
    RUN disk_read
    DRP
    DRP
    DRP
    LOD R1
    DRP
    PSH 0
    DRP
    PSH 0
    DRP
    PSH 64
    LOD FP
    PSH -560
    ADD
    PSH 1
    RUN disk_read
    DRP
    DRP
    DRP
    LOD R1
    DRP
    PSH 10
    PSH 10
    PSH .L..18
    PSH 255
    RUN draw_string
    DRP
    DRP
    DRP
    DRP
    LOD R1
    DRP
    PSH 10
    PSH 25
    PSH .L..19
    PSH 200
    RUN draw_string
    DRP
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
    PSH -48
    ADD
    PSH 0
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
    PSH -44
    ADD
    PSH 45
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
    PSH -40
    ADD
    PSH 0
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
.L.begin.3:
    LOD FP
    PSH -40
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 16
    PUT R2
    DRP
    PUT R1
    DRP
    CMP R1, R2
    JLT .L.true.4
    PSH 0
    JMP .L.end.4
.L.true.4:
    PSH 1
.L.end.4:
    PUT R1
    DRP
    MOV R2, 0
    CMP R1, R2
    JIE .L..20
    LOD FP
    PSH -560
    ADD
    LOD FP
    PSH -40
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 32
    MUL
    ADD
    PSH 0
    ADD
    PSH 0
    PSH 1
    MUL
    ADD
    PUT R3
    DRP
    LDB R3
    PSH 0
    PUT R2
    DRP
    PUT R1
    DRP
    CMP R1, R2
    JGT .L.true.10
    JLT .L.true.10
    PSH 0
    JMP .L.end.10
.L.true.10:
    PSH 1
.L.end.10:
    PUT R1
    DRP
    MOV R2, 0
    CMP R1, R2
    JIE .L.else.5
    PSH 10
    LOD FP
    PSH -44
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 48
    LOD FP
    PSH -40
    ADD
    PUT R3
    DRP
    LDI R3
    ADD
    PSH 255
    RUN draw_char
    DRP
    DRP
    DRP
    DRP
    LOD R1
    DRP
    PSH 20
    LOD FP
    PSH -44
    ADD
    PUT R3
    DRP
    LDI R3
    PSH .L..22
    PSH 255
    RUN draw_string
    DRP
    DRP
    DRP
    DRP
    LOD R1
    DRP
    PSH 30
    LOD FP
    PSH -44
    ADD
    PUT R3
    DRP
    LDI R3
    LOD FP
    PSH -560
    ADD
    LOD FP
    PSH -40
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 32
    MUL
    ADD
    PSH 0
    ADD
    PSH 255
    RUN draw_string
    DRP
    DRP
    DRP
    DRP
    LOD R1
    DRP
    LOD FP
    PSH -44
    ADD
    LOD FP
    PSH -44
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
    LOD FP
    PSH -48
    ADD
    LOD FP
    PSH -48
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
    JMP .L.end.5
.L.else.5:
.L.end.5:
.L..21:
    LOD FP
    PSH -40
    ADD
    LOD FP
    PSH -40
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
    JMP .L.begin.3
.L..20:
    RUN render
    LOD R1
    DRP
    PSH 0
    DRP
    PSH 0
    DRP
    LOD FP
    PSH -36
    ADD
    PSH 1
    PSH -1
    MUL
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
.L.begin.17:
    LOD FP
    PSH -36
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 1
    PSH -1
    MUL
    PUT R2
    DRP
    PUT R1
    DRP
    CMP R1, R2
    JIE .L.true.18
    PSH 0
    JMP .L.end.18
.L.true.18:
    PSH 1
.L.end.18:
    PUT R1
    DRP
    MOV R2, 0
    CMP R1, R2
    JIE .L..23
    PSH 0
    DRP
    PSH 0
    DRP
    LOD FP
    PSH -32
    ADD
    PSH 0
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
.L.begin.19:
    LOD FP
    PSH -32
    ADD
    PUT R3
    DRP
    LDI R3
    LOD FP
    PSH -48
    ADD
    PUT R3
    DRP
    LDI R3
    PUT R2
    DRP
    PUT R1
    DRP
    CMP R1, R2
    JLT .L.true.20
    PSH 0
    JMP .L.end.20
.L.true.20:
    PSH 1
.L.end.20:
    PUT R1
    DRP
    MOV R2, 0
    CMP R1, R2
    JIE .L..25
    PSH keys
    PUT R3
    DRP
    LDI R3
    PSH 48
    LOD FP
    PSH -32
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
    PUT R1
    DRP
    MOV R2, 0
    CMP R1, R2
    JIE .L.else.21
    LOD FP
    PSH -36
    ADD
    LOD FP
    PSH -32
    ADD
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
    JMP .L.end.21
.L.else.21:
.L.end.21:
.L..26:
    LOD FP
    PSH -32
    ADD
    LOD FP
    PSH -32
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
    JMP .L.begin.19
.L..25:
    RUN render
    LOD R1
    DRP
.L..24:
    JMP .L.begin.17
.L..23:
    PSH 0
    DRP
    PSH 0
    DRP
    LOD FP
    PSH -28
    ADD
    LOD FP
    PSH -560
    ADD
    LOD FP
    PSH -36
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 32
    MUL
    ADD
    PSH 24
    ADD
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
    DRP
    PSH 0
    DRP
    LOD FP
    PSH -24
    ADD
    LOD FP
    PSH -560
    ADD
    LOD FP
    PSH -36
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 32
    MUL
    ADD
    PSH 28
    ADD
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
    DRP
    PSH 0
    DRP
    LOD FP
    PSH -20
    ADD
    LOD FP
    PSH -24
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 512
    DIV
    PSH 1
    ADD
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
    PSH 200000
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
    LOD FP
    PSH -28
    ADD
    PUT R3
    DRP
    LDI R3
    LOD FP
    PSH -16
    ADD
    PUT R3
    DRP
    LDI R3
    LOD FP
    PSH -20
    ADD
    PUT R3
    DRP
    LDI R3
    RUN disk_read
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
.L.begin.32:
    LOD FP
    PSH -4
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 64000
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
    JIE .L..27
    PSH vram
    PUT R3
    DRP
    LDI R3
    LOD FP
    PSH -4
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 1
    MUL
    ADD
    PSH 0
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STB R3
    DRP
.L..28:
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
    JMP .L.begin.32
.L..27:
    RUN render
    LOD R1
    DRP
  PSH 200000
  RET
    PSH 0
    PUT R1
    DRP
    JMP .L.return.main
    PSH 0
.L.return.main:
    LEV
    RET
draw_string:
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
    LOD FP
    PSH 20
    ADD
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
.L.begin.37:
    LOD FP
    PSH 12
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
    PSH 1
    MUL
    ADD
    PUT R3
    DRP
    LDB R3
    PSH 0
    PUT R2
    DRP
    PUT R1
    DRP
    CMP R1, R2
    JGT .L.true.40
    JLT .L.true.40
    PSH 0
    JMP .L.end.40
.L.true.40:
    PSH 1
.L.end.40:
    PUT R1
    DRP
    MOV R2, 0
    CMP R1, R2
    JIE .L..14
    LOD FP
    PSH -8
    ADD
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
    PSH 12
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
    PSH 1
    MUL
    ADD
    PUT R3
    DRP
    LDB R3
    LOD FP
    PSH 8
    ADD
    PUT R3
    DRP
    LDI R3
    RUN draw_char
    DRP
    DRP
    DRP
    DRP
    LOD R1
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
    PSH 8
    ADD
    PUT R4
    DRP
    PUT R3
    DRP
    LOD R4
    STI R3
    DRP
.L..15:
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
    JMP .L.begin.37
.L..14:
.L.return.draw_string:
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
    DRP
    PSH 0
    DRP
    LOD FP
    PSH -16
    ADD
    LOD FP
    PSH 12
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 8
    MUL
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
.L.begin.46:
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
    JLT .L.true.47
    PSH 0
    JMP .L.end.47
.L.true.47:
    PSH 1
.L.end.47:
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
    PSH -8
    ADD
    PSH font
    PUT R3
    DRP
    LDI R3
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
.L.begin.51:
    LOD FP
    PSH -4
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
    JLT .L.true.52
    PSH 0
    JMP .L.end.52
.L.true.52:
    PSH 1
.L.end.52:
    PUT R1
    DRP
    MOV R2, 0
    CMP R1, R2
    JIE .L..10
    LOD FP
    PSH -8
    ADD
    PUT R3
    DRP
    LDI R3
    PSH 7
    LOD FP
    PSH -4
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
    JIE .L.else.53
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
    PSH -12
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
    JMP .L.end.53
.L.else.53:
.L.end.53:
.L..11:
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
    JMP .L.begin.51
.L..10:
.L..9:
    LOD FP
    PSH -12
    ADD
    LOD FP
    PSH -12
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
    JMP .L.begin.46
.L..8:
.L.return.draw_char:
    LEV
    RET
render:
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
  MOV RS, RENDER
  SYS
.L.return.render:
    LEV
    RET
disk_read:
    ENT
    PSH 0
    PSH 0
    PSH 0
    PSH 0
    PSH sys_rx
    LOD FP
    PSH 16
    ADD
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
    PSH sys_ry
    LOD FP
    PSH 12
    ADD
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
    PSH sys_rc
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
    STI R3
    DRP
    RUN _do_disk_read
    LOD R1
    DRP
.L.return.disk_read:
    LEV
    RET
_do_disk_read:
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
  LOD sys_rx
  PUT RX
  DRP
  LOD sys_ry
  PUT RY
  DRP
  LOD sys_rc
  PUT RC
  DRP
  MOV RS, DISK_READ
  SYS
.L.return._do_disk_read:
    LEV
    RET
