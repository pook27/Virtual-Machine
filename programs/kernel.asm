; -----------------------------------------
; SECTOR 1: THE OPERATING SYSTEM
; -----------------------------------------

JMP OS_MAIN

OS_WELCOME:
    .STRING "Loading Virtual OS Kernel from Hard Drive...\n"

OS_MAIN:
    ; 1. Clear the screen
    MOV RS, SYS_CLEAR
    SYS

    ; 2. Print success message
    MOV RS, SYS_STRING
    MOV RC, OS_WELCOME
    SYS

    ; The OS idles here forever, waiting for interrupts
    HLT
