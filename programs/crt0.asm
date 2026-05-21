; ==========================================
; CRT0.ASM - C Runtime Entry
; ==========================================
    PSH 0
    RUN main
    MOV RS, EXIT
    SYS
