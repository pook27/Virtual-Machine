; 1. Jump over the data section so we don't accidentally execute text!
JMP MAIN

; -----------------------------
; --- DATA SECTION ------------
; -----------------------------
MY_MESSAGE:
    .STRING "Hello, Virtual World!\n"

ANOTHER_MSG:
    .STRING "Assembly is awesome.\n"


; -----------------------------
; --- CODE SECTION ------------
; -----------------------------
MAIN:
    ; Print the first string
    MOV RS, STRING
    MOV RC, MY_MESSAGE      ; Loads the label's memory address into RX
    SYS

    ; Print the second string
    MOV RS, STRING
    MOV RC, ANOTHER_MSG
    SYS

    ; Exit gracefully
    MOV RS, EXIT
    SYS
