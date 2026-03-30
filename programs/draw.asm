; Clear the screen
MOV RS, 2       ; Syscall 2: Clear Screen
SYS             ; Execute Syscall

; Draw a block at X=10, Y=5
MOV RS, 3       ; Syscall 3: Draw Block
MOV RX, 10      ; X coordinate
MOV RY, 5       ; Y coordinate
SYS             ; Execute Syscall

; Draw another block at X=12, Y=6
MOV RS, 3       ; Syscall 3: Draw Block
MOV RX, 12      ; X coordinate
MOV RY, 6       ; Y coordinate
SYS             ; Execute Syscall

; Exit cleanly
MOV RS, 99      ; Syscall 99: Exit
SYS
