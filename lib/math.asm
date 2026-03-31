; A reusable library! 
.DEFINE SYS_PRINT_NUM 1   ; Assuming you map a syscall to print numbers, or use POP

DOUBLE_IT:
    ENT
    LOD R1
    PSH 2
    MUL
    PUT R1
    DRP
    LEV
    RET
