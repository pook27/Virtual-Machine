.TEXT
JMP MAIN_ENTRY

.DATA
velocity_x: 2
.DATA
player_x: 160
.TEXT
MAIN_ENTRY:
LOOP_START:
    LOD player_x
    LOD velocity_x
    ADD
    PUT player_x
    DRP

    JMP LOOP_START
    JMP LOOP_START
