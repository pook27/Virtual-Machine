.DEFINE VRAM 1048576 
JMP OS_MAIN

OS_MAIN:
    ; Just color the screen Red (224) to prove the kernel booted!
    MOV R0, 224
    PSH R0
    MOV R1, VRAM
    STB [R1]

IDLE:
    MOV RS, RENDER
    SYS
    JMP IDLE
