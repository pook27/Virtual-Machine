; -----------------------------------------
; OS SHELL LIBRARY (Full String Router)
; -----------------------------------------
.DATA
LS_DIR_PTR: 0
LS_ENTRY_CNT: 0
LS_CHAR_IDX: 0

; --- COMMAND STRINGS ---
; The assembler now perfectly unwraps these!
STR_LS: "ls"
STR_PWD: "pwd"
STR_DVD: "dvd"
STR_CLEAR: "clear"

.TEXT

; -----------------------------------------
; ROUTER: MATCHES TYPED STRING TO COMMAND
; -----------------------------------------
PROCESS_COMMAND:
    MOV R1, CMD_BUFFER
    MOV R2, STR_LS
    RUN STR_CMP
    MOV R0, 1
    CMP RX, R0
    JIE CMD_LS

    MOV R1, CMD_BUFFER
    MOV R2, STR_PWD
    RUN STR_CMP
    MOV R0, 1
    CMP RX, R0
    JIE CMD_PWD

    MOV R1, CMD_BUFFER
    MOV R2, STR_DVD
    RUN STR_CMP
    MOV R0, 1
    CMP RX, R0
    JIE BOOT_DVD

    MOV R1, CMD_BUFFER
    MOV R2, STR_CLEAR
    RUN STR_CMP
    MOV R0, 1
    CMP RX, R0
    JIE CMD_CLEAR
    
    MOV R1, CMD_BUFFER
    MOV R2, STR_TEST
    RUN STR_CMP
    MOV R0, 1
    CMP RX, R0
    JIE CMD_CLEAR

    RET     ; Unknown command, return to Kernel!

; -----------------------------------------
; SUBROUTINE: STRING COMPARE (STR_CMP)
; R1 = Typed Buffer Pointer (8-bit bytes)
; R2 = Data String Pointer (32-bit ints)
; Returns: RX = 1 (Match), RX = 0 (Mismatch)
; -----------------------------------------
STR_CMP:
STR_CMP_LOOP:
    LDB R1          ; Read 8-bit byte from typed buffer
    PUT R3          
    DRP
    
    LDI R2          ; <--- FIXED: LDI reads the 32-bit int AT the pointer!
    PUT R4          
    DRP

    CMP R3, R4      ; Are the letters the same?
    JIE STR_CMP_CONT
    
    ; MISMATCH!
    MOV RX, 0
    RET

STR_CMP_CONT:
    ; The letters matched! But did we reach the end (Null Terminator)?
    MOV R0, 0
    CMP R3, R0
    JIE STR_CMP_MATCH

    ; Move to the next letter
    LOD R1
    PSH 1           ; BUFFER pointer increments by 1 byte
    ADD
    PUT R1
    DRP

    LOD R2
    PSH 4           ; DATA string pointer increments by 4 bytes!
    ADD
    PUT R2
    DRP
    JMP STR_CMP_LOOP

STR_CMP_MATCH:
    MOV RX, 1       ; IT'S A PERFECT MATCH!
    RET

; -----------------------------------------
; COMMAND: CLEAR
; -----------------------------------------
CMD_CLEAR:
    MOV RS, CLEAR
    SYS
    MOV CURSOR_X, 10
    MOV CURSOR_Y, 20
    RET

; -----------------------------------------
; COMMAND: PWD
; -----------------------------------------
CMD_PWD:
    RUN DO_NEWLINE
    LOD CURSOR_X
    PUT R1
    DRP
    LOD CURSOR_Y
    PUT R2
    DRP
    MOV R3, 47      ; ASCII '/'
    MOV R4, 115     ; Sky Blue
    RUN DRAW_CHAR
    RET

; -----------------------------------------
; COMMAND: LS (Loops through Sector 9)
; -----------------------------------------
CMD_LS:
    RUN DO_NEWLINE
    MOV LS_DIR_PTR, 8192  
    MOV LS_ENTRY_CNT, 0

LS_LOOP:
    MOV R0, 16      
    CMP LS_ENTRY_CNT, R0
    JIE CMD_LS_DONE

    LDB LS_DIR_PTR
    PUT R1
    DRP
    MOV R0, 0
    CMP R1, R0
    JIE LS_NEXT

    MOV LS_CHAR_IDX, 0
LS_PRINT_LOOP:
    MOV R0, 24      
    CMP LS_CHAR_IDX, R0
    JIE LS_PRINT_DONE

    LOD LS_DIR_PTR
    LOD LS_CHAR_IDX
    ADD
    PUT R0
    DRP
    LDB R0
    PUT R3
    DRP

    MOV R0, 0
    CMP R3, R0
    JIE LS_PRINT_DONE

    LOD CURSOR_X
    PUT R1
    DRP
    LOD CURSOR_Y
    PUT R2
    DRP
    MOV R4, 115
    RUN DRAW_CHAR

    LOD CURSOR_X
    PSH 10
    ADD
    PUT CURSOR_X
    DRP

    LOD LS_CHAR_IDX
    PSH 1
    ADD
    PUT LS_CHAR_IDX
    DRP
    JMP LS_PRINT_LOOP

LS_PRINT_DONE:
    RUN DO_NEWLINE

LS_NEXT:
    LOD LS_DIR_PTR
    PSH 32
    ADD
    PUT LS_DIR_PTR
    DRP

    LOD LS_ENTRY_CNT
    PSH 1
    ADD
    PUT LS_ENTRY_CNT
    DRP
    JMP LS_LOOP

CMD_LS_DONE:
    RET

; -----------------------------------------
; HELPER: MOVE CURSOR DOWN
; -----------------------------------------
DO_NEWLINE:
    LOD CURSOR_Y
    PSH 12
    ADD
    PUT CURSOR_Y
    DRP
    MOV CURSOR_X, 10
    RET

; -----------------------------------------
; PROGRAM EXECUTION: BOOT_DVD
; -----------------------------------------
BOOT_DVD:
    RUN DO_NEWLINE
    
    ; DVD is entry #2 in Sector 9. Offset = 8192 + 32 + 24 = 8248
    PSH 8248
    PUT R0
    DRP
    LDB R0      ; Fetch Start Sector
    PUT RX
    DRP

    MOV RS, DISK_READ
    MOV RY, USER_RAM
    MOV RC, 5
    SYS

    RUN USER_RAM
    
    MOV RS, CLEAR
    SYS
    RET
