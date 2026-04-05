.TEXT
JMP MAIN_ENTRY

.DATA
player_x: 10
.DATA
player_y: 100
.DATA
velocity_x: 1
.TEXT
MAIN_ENTRY:
LOOP_START:
    MOV RS, 2
    SYS

    LOD player_y
    PSH 320
    MUL
    LOD player_x
    ADD
    PSH 1048576
    ADD
    PUT R3
    DRP
    PSH 40
    STB R3
    DRP

    MOV RS, 7
    SYS

    LOD player_x
    LOD velocity_x
    ADD
    PUT player_x
    DRP

    JMP LOOP_START
    JMP LOOP_START
