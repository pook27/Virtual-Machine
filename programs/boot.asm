; -----------------------------------------
; SECTOR 0: THE MASTER BOOT RECORD
; -----------------------------------------
.DEFINE KERNEL_RAM 4096  ; Load OS into RAM at 4096

    MOV RS, DISK_READ
    MOV RX, 1           ; Source: Read Sector 1 of drive.img
    MOV RY, KERNEL_RAM  ; Dest: Write to RAM Address 4096
    SYS

    ; Hand completely over to the OS!
    JMP KERNEL_RAM
