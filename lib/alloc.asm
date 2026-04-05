; -----------------------------------------
; OS SYSTEM HEAP MANAGER
; Provides MALLOC and FREE subroutines
; -----------------------------------------
.DEFINE HEAP_START 100000
.DEFINE HEAP_END 500000

.DATA
HEAP_PTR: 0
NEEDED_SIZE: 0
NEXT_BLOCK: 0

.TEXT

; -----------------------------------------
; INIT_HEAP (Called once on OS Boot)
; -----------------------------------------
INIT_HEAP:
    ; Set up the very first massive Free Block
    PSH HEAP_START
    PUT R1
    DRP

    ; IS_ALLOCATED = 0 (Free)
    PSH 0
    STI R1
    DRP

    ; BLOCK_SIZE = 400000 (Total Heap Size)
    LOD R1
    PSH 4
    ADD
    PUT R1
    DRP

    PSH 400000
    STI R1
    DRP
    RET

; -----------------------------------------
; MALLOC: Find a free block and split it!
; R1 = Requested Bytes. 
; Returns: RX = Pointer to Memory (or 0 if failed)
; -----------------------------------------
MALLOC:
    MOV HEAP_PTR, HEAP_START

MALLOC_LOOP:
    MOV R0, HEAP_END
    CMP HEAP_PTR, R0
    JIE MALLOC_FAIL     ; We hit the end of the heap!

    LDI HEAP_PTR        ; Read IS_ALLOCATED
    PUT R2
    DRP

    LOD HEAP_PTR
    PSH 4
    ADD
    PUT R3              ; R3 = Memory Address of BLOCK_SIZE
    DRP

    LDI R3              ; Read the actual BLOCK_SIZE
    PUT R4
    DRP

    ; Is it Free? (R2 == 0)
    MOV R0, 0
    CMP R2, R0
    JIE MALLOC_CHECK_SIZE
    JMP MALLOC_NEXT

MALLOC_CHECK_SIZE:
    ; Calculate total needed: Requested (R1) + 8 byte Header
    LOD R1
    PSH 8
    ADD
    PUT NEEDED_SIZE
    DRP

    LOD NEEDED_SIZE
    PUT R0
    DRP

    ; Is Available (R4) >= Needed (R0)?
    CMP R4, R0
    JGT MALLOC_SPLIT    ; It's bigger than we need!
    JIE MALLOC_SPLIT    ; It's exactly the size we need!
    JMP MALLOC_NEXT     ; It's too small, skip it!

MALLOC_SPLIT:
    ; 1. Mark this block as USED
    PSH 1
    STI HEAP_PTR
    DRP

    ; 2. Shrink current block to just the size we need
    LOD NEEDED_SIZE
    STI R3
    DRP

    ; 3. Create a new FREE header right after our block!
    LOD HEAP_PTR
    LOD NEEDED_SIZE
    ADD
    PUT NEXT_BLOCK
    DRP

    ; Next Block IS_ALLOCATED = 0
    PSH 0
    STI NEXT_BLOCK
    DRP

    ; Next Block BLOCK_SIZE = Old Available (R4) - Needed Size
    LOD NEXT_BLOCK
    PSH 4
    ADD
    PUT R2              ; R2 = Address of Next Block's Size
    DRP

    LOD R4
    LOD NEEDED_SIZE
    SUB
    STI R2
    DRP

    ; 4. Return the Pointer to the DATA (Heap Ptr + 8)
    LOD HEAP_PTR
    PSH 8
    ADD
    PUT RX
    DRP
    RET

MALLOC_NEXT:
    ; Advance HEAP_PTR by the BLOCK_SIZE (R4) to look at the next block
    LOD HEAP_PTR
    LOD R4
    ADD
    PUT HEAP_PTR
    DRP
    JMP MALLOC_LOOP

MALLOC_FAIL:
    MOV RX, 0           ; Return NULL! Out of Memory!
    RET

; -----------------------------------------
; FREE: Release memory back to the OS
; R1 = Pointer returned by Malloc
; -----------------------------------------
FREE:
    ; To find the header, just subtract 8 from the pointer!
    LOD R1
    PSH 8
    SUB
    PUT R2
    DRP

    ; Set IS_ALLOCATED to 0
    PSH 0
    STI R2
    DRP
    RET
