; 1. Shift Left: 1 << 3 = 8
PSH 1
PSH 3
SHL
POP

; 2. Bitwise AND: 6 (110) AND 3 (011) = 2 (010)
PSH 6
PSH 3
AND
POP

; 3. Bitwise ORR: 4 (100) ORR 1 (001) = 5 (101)
PSH 4
PSH 1
ORR
POP

HLT
