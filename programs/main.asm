.DATA
my_score: 50
greeting: .STRING "Starting Game...\n"

.TEXT
    ; 1. Print our string using standard syscall
    MOV RS, STRING               ; Syscall 5 = STRING
    MOV RC, greeting
    SYS

    ; 2. Load our variable directly (No brackets needed!)
    LOD my_score
    POP                     ; Prints 50

    ; 3. Use the included library function
    LOD my_score
    PUT R1                  ; Set up R1 for the function
    DRP

    RUN DOUBLE_IT           ; Call function from math_lib.asm

    ; 4. Save result back to the variable!
    LOD R1                  
    PUT my_score            
    DRP

    LOD my_score
    POP                     ; Prints 100!

    HLT

%include lib/math.asm
