; Initialize R0 to 0
START:
    MOV R0, 0     

; Main loop
LOOP:
    PSH 1         
    LOD R0        
    ADD           
    PUT R0        
    POP           
    JMP LOOP      ; Will automatically resolve to index 3

    HLT
