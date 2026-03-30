; Store 99 at memory address 500
MOV R1, 500
PSH 99
PUT [R1]      ; Translates to STI R1
DRP

; Load it back and print it
LOD [R1]      ; Translates to LDI R1
POP
HLT
