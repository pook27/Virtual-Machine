MOV RS, 2       ; Syscall 2: Clear Screen
SYS
MOV RX, 0       ; Start X at 0
MOV RY, 15      ; Start Y at 15

LOOP:
    ; 1. Draw the pixel
    MOV RS, 3       ; Syscall 3: Draw Block
    SYS

    ; 2. Pause so the human eye can see it
    MOV RS, 4       ; Syscall 4: Sleep
    SYS

    ; 3. Clear the screen for the next frame
    MOV RS, 2       ; Syscall 2: Clear Screen
    SYS

    ; 4. Add 1 to RX
    PSH 1
    LOD RX
    ADD
    PUT RX
    POP

    ; 5. Loop back
    JMP LOOP

    HLT
