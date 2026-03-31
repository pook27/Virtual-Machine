.DATA
player_hp: 100
damage_taken: 35

.TEXT
; Calculate: player_hp - damage_taken
LOD player_hp
LOD damage_taken
SUB
PUT player_hp   ; Save it back
DRP

LOD player_hp
POP             ; Should print 65

HLT
