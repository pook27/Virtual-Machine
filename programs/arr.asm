; Define an array start point
MOV R1, 100     ; R1 is our pointer

; Store a value into the array
PSH 42          ; Push 42 to stack
PUT [R1]        ; Syntactic sugar! Assembler turns this into STI R1
DRP             ; Clean up stack

; Load a value from the array
LOD [R1]        ; Syntactic sugar! Assembler turns this into LDI R1
POP             ; Prints 42!
