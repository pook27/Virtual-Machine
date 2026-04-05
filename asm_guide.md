# Custom VM Assembly Language — Reference Guide

---

## Table of Contents
1. [Registers](#registers)
2. [Instructions](#instructions)
   - [Stack Operations](#stack-operations)
   - [Arithmetic](#arithmetic)
   - [Bitwise Operations](#bitwise-operations)
   - [Memory & Registers](#memory--registers)
   - [Control Flow](#control-flow)
   - [Subroutines & Stack Frames](#subroutines--stack-frames)
   - [System Calls](#system-calls)
3. [Assembler Directives](#assembler-directives)
4. [Syscall Reference](#syscall-reference)
5. [Memory Map](#memory-map)
6. [Quick Reference Card](#quick-reference-card)

---

## Registers

Registers are fixed memory-mapped addresses used to pass arguments, store results, and control program state. They are accessed by name in any instruction that takes an address.

| Register | Purpose |
|----------|---------|
| `R0` | General-purpose register 0. |
| `R1` | General-purpose register 1; conventionally used as the primary argument and return value for subroutines. |
| `R2` | General-purpose register 2; conventionally used as the secondary argument for subroutines. |
| `R3` | General-purpose register 3; commonly used as a scratch/temporary pointer. |
| `R4` | General-purpose register 4; commonly used as an accumulator in loops. |
| `RS` | **Syscall selector** — set this to the syscall number before executing `SYS`. |
| `RC` | **Syscall argument C** — typically holds a string/memory address or a sector count for syscalls. |
| `RX` | **Syscall argument X** — typically holds an X coordinate, disk sector number, or sleep duration. |
| `RY` | **Syscall argument Y** — typically holds a Y coordinate or a destination RAM address. |
| `FP` | **Frame Pointer** — managed automatically by `ENT`/`LEV` to track the current stack frame. |

---

## Instructions

### Stack Operations

The VM is stack-based. Most arithmetic and logic operations pop their operands from the stack and push the result back.

| Instruction | Syntax | Description |
|-------------|--------|-------------|
| `PSH` | `PSH <value>` | Pushes a literal integer value onto the top of the stack. |
| `POP` | `POP` | Pops the top value off the stack and, in headless mode, prints it to stdout. |
| `DRP` | `DRP` | Discards (drops) the top value from the stack without printing it; used for stack cleanup. |

**Example:**
```asm
PSH 10
PSH 5
ADD         ; Stack now has 15 on top
POP         ; Prints: 15
```

---

### Arithmetic

All arithmetic instructions pop their two operands from the stack (right operand popped first) and push the result.

| Instruction | Syntax | Description |
|-------------|--------|-------------|
| `ADD` | `ADD` | Pops two values and pushes their sum (`b + a`). |
| `SUB` | `SUB` | Pops two values and pushes their difference (`b - a`). |
| `MUL` | `MUL` | Pops two values and pushes their product (`b * a`). |
| `DIV` | `DIV` | Pops two values and pushes the integer quotient (`b / a`); halts on divide-by-zero. |
| `MOD` | `MOD` | Pops two values and pushes the remainder (`b % a`); halts on divide-by-zero. |

**Example:**
```asm
PSH 17
PSH 5
DIV         ; Pushes 3
POP         ; Prints: 3

PSH 17
PSH 5
MOD         ; Pushes 2
POP         ; Prints: 2
```

---

### Bitwise Operations

Bitwise instructions operate on the raw binary representation of integer values.

| Instruction | Syntax | Description |
|-------------|--------|-------------|
| `AND` | `AND` | Pops two values and pushes their bitwise AND. |
| `ORR` | `ORR` | Pops two values and pushes their bitwise OR. |
| `XOR` | `XOR` | Pops two values and pushes their bitwise XOR. |
| `NOT` | `NOT` | Pops one value and pushes its bitwise complement (all bits flipped). |
| `SHL` | `SHL` | Pops two values and pushes `b` shifted left by `a` bits. |
| `SHR` | `SHR` | Pops two values and pushes `b` shifted right by `a` bits. |

**Example:**
```asm
PSH 1
PSH 3
SHL         ; 1 << 3 = 8
POP         ; Prints: 8
```

---

### Memory & Registers

These instructions read and write 32-bit words or individual bytes to/from memory addresses and registers.

| Instruction | Syntax | Description |
|-------------|--------|-------------|
| `MOV` | `MOV <reg>, <value>` | Directly writes a literal value into a register without touching the stack. |
| `LOD` | `LOD <addr>` | Reads the 32-bit value stored at `<addr>` and pushes it onto the stack. |
| `PUT` | `PUT <addr>` | Writes the top-of-stack value to `<addr>` without popping it (peek, not pop). |
| `LDI` | `LDI <addr>` | **Indirect load** — reads the address stored at `<addr>`, then pushes the 32-bit value *at that address*. |
| `STI` | `STI <addr>` | **Indirect store** — reads the address stored at `<addr>`, then writes the top-of-stack there. |
| `LDB` | `LDB <addr>` | **Load byte** — reads the address stored at `<addr>`, then pushes the single *byte* at that address. |
| `STB` | `STB <addr>` | **Store byte** — reads the address stored at `<addr>`, then writes the lowest byte of the top-of-stack there. |

> **Note on `LDI`/`STI` bracket syntax:** Some example programs use `LOD [R1]` and `PUT [R1]` as shorthand, but this is **not supported** by the assembler's tokenizer. Always use `LDI R1` and `STI R1` directly.

**Example:**
```asm
MOV R1, 500     ; R1 = 500 (a memory address)
PSH 99
STI R1          ; Write 99 to address 500
DRP

LDI R1          ; Push value at address 500 (99)
POP             ; Prints: 99
```

---

### Control Flow

Comparison and jump instructions control the program's execution path. `CMP` sets an internal flag, which the conditional jumps then read.

| Instruction | Syntax | Description |
|-------------|--------|-------------|
| `JMP` | `JMP <label>` | Unconditionally sets the program counter to the target address or label. |
| `CMP` | `CMP <addr_a>, <addr_b>` | Compares the values at two addresses, setting an internal flag: `0` if equal, `1` if `a > b`, `-1` if `a < b`. |
| `JIE` | `JIE <label>` | **Jump If Equal** — jumps to the label if the last `CMP` result was equal (flag == 0). |
| `JGT` | `JGT <label>` | **Jump If Greater** — jumps to the label if the last `CMP` left `a > b` (flag == 1). |
| `JLT` | `JLT <label>` | **Jump If Less** — jumps to the label if the last `CMP` left `a < b` (flag == -1). |
| `HLT` | `HLT` | Stops execution of the VM entirely; the main loop exits when it encounters this opcode. |

**Example:**
```asm
MOV R1, -5
MOV R2, 0
CMP R1, R2
JLT IS_NEGATIVE     ; -5 < 0, so this jumps
JMP DONE

IS_NEGATIVE:
    LOD R1
    POP             ; Prints: -5

DONE:
    HLT
```

---

### Subroutines & Stack Frames

These instructions manage calling and returning from subroutines, optionally with a proper stack frame for local variable isolation.

| Instruction | Syntax | Description |
|-------------|--------|-------------|
| `RUN` | `RUN <label>` | Calls a subroutine — pushes the current program counter (return address) onto the stack and jumps to `<label>`. |
| `RET` | `RET` | Returns from a subroutine — pops the return address off the stack and jumps to it. |
| `RTI` | `RTI` | **Return from Interrupt** — identical to `RET` but semantically reserved for interrupt handlers. |
| `ENT` | `ENT` | **Enter frame** — saves the current `FP` onto the stack and sets `FP` to the current stack pointer, establishing a new stack frame. |
| `LEV` | `LEV` | **Leave frame** — restores the stack pointer from `FP` and pops the old `FP`, tearing down the current stack frame. |

> **Convention:** Use `ENT` at the start and `LEV` immediately before `RET` in subroutines that need a clean stack frame. Simple leaf subroutines (no nested calls, no stack variables) can skip `ENT`/`LEV` and just use `RET`.

**Example:**
```asm
JMP MAIN

DOUBLE_R1:
    ENT             ; Save frame pointer
    LOD R1
    PSH 2
    MUL
    PUT R1          ; R1 = R1 * 2
    DRP
    LEV             ; Restore frame pointer
    RET

MAIN:
    MOV R1, 21
    RUN DOUBLE_R1
    LOD R1
    POP             ; Prints: 42
    HLT
```

---

### System Calls

`SYS` invokes the operating system to perform hardware actions. Set `RS` to the syscall number and load any arguments into the appropriate registers before calling.

| Instruction | Syntax | Description |
|-------------|--------|-------------|
| `SYS` | `SYS` | Triggers the syscall specified by the value in `RS`, using `RC`, `RX`, `RY` as arguments. |

See the [Syscall Reference](#syscall-reference) section below for all available syscalls.

---

## Assembler Directives

Directives are assembler-time commands that control how your source file is processed. They are not emitted as instructions.

| Directive | Syntax | Description |
|-----------|--------|-------------|
| `.DATA` | `.DATA` | Switches the assembler to the **data section**; tokens here are placed before the text section in the binary and skipped over at runtime by an auto-generated `JMP`. |
| `.TEXT` | `.TEXT` | Switches the assembler back to the **text (code) section** after a `.DATA` block. |
| `.STRING` | `.STRING "text"` | Encodes a null-terminated string as a sequence of integer tokens inline at the current position; supports `\n`, `\t`, `\\`, and `\"` escape sequences. |
| `.DEFINE` | `.DEFINE <NAME> <value>` | Creates a text-substitution macro; every subsequent occurrence of `<NAME>` is replaced with `<value>` at assemble time. |
| `%include` | `%include <file.asm>` | Pastes the contents of another assembly file at the current position, enabling code reuse across files. |
| `LABEL:` | `MY_LABEL:` | Defines a label at the current token position; the label resolves to the absolute memory address of the next instruction or data value. |

**Example:**
```asm
.DEFINE MAX_HP 100

.DATA
player_hp: MAX_HP       ; Stored as 100 in the data section

.TEXT
    LOD player_hp
    POP                 ; Prints: 100
    HLT

%include lib/math.asm   ; Paste the math library here
```

---

## Syscall Reference

Set `RS` to the syscall number (or its name via `.DEFINE`) before executing `SYS`.

| Name | Value | Arguments | Description |
|------|-------|-----------|-------------|
| `CHAR` | `1` | `RC` = ASCII code | Prints a single character to stdout (headless mode only). |
| `CLEAR` | `2` | — | Fills the entire VRAM framebuffer with black (display mode only). |
| `DRAW` | `3` | `RX` = x, `RY` = y | Draws a single block/pixel at the given screen coordinates (legacy). |
| `SLEEP` | `4` | `RX` = milliseconds | Pauses execution for the given number of milliseconds. |
| `STRING` | `5` | `RC` = address of string | Prints a null-terminated string from memory to stdout (headless mode only). |
| `INPUT` | `6` | — | Reads the most recently pressed key and stores its ASCII code into `RC` (display mode only). |
| `RENDER` | `7` | — | Flushes the VRAM framebuffer to the screen window and polls keyboard state into the MMIO keyboard array. |
| `DISK_READ` | `8` | `RX` = start sector, `RY` = dest address, `RC` = sector count | Reads one or more 512-byte sectors from `drive.img` into RAM at the destination address. |
| `DISK_WRITE` | `9` | `RX` = start sector, `RY` = source address | Writes one 512-byte sector from RAM to `drive.img` at the given sector. |
| `EXIT` | `99` | — | Terminates the VM process immediately. |

**Example:**
```asm
JMP MAIN
MSG: .STRING "Hello, World!\n"

MAIN:
    MOV RS, STRING
    MOV RC, MSG
    SYS

    MOV RS, EXIT
    SYS
```

---

## Memory Map

The VM has an 8 MB address space with fixed regions for hardware I/O.

| Address Range | Size | Purpose |
|---------------|------|---------|
| `0x00000000` | 512 B | **Sector 0** — bootloader loaded here on cold start. |
| `0x00001000` (4096) | ~4 KB | Conventional kernel load address (see `boot.asm`). |
| `0x00002000` (8192) | 512 B | Conventional directory table load address. |
| `0x00004E20` (20000) | — | Conventional user program load address ("user space"). |
| `0x00100000` | 64,000 B | **VRAM** — 320×200 pixel framebuffer; each byte is a palette index. |
| `0x00200000` | 350 B | **MMIO Keyboard Array** — each byte index corresponds to a Raylib key code; `1` = pressed, `0` = not pressed. |
| `0x007FFF00` | 40 B | **Register File** — `R0`–`FP` mapped here as 4-byte slots. |

### Palette
VRAM uses an 8-bit indexed colour palette (0–255). Each index encodes RGB as:
- **Red**: bits 7–5 (3 bits, 0–7 → 0–255)
- **Green**: bits 4–2 (3 bits, 0–7 → 0–255)
- **Blue**: bits 1–0 (2 bits, 0–3 → 0–255)

### VRAM Addressing Formula
```
address = VRAM_BASE + (y * 320) + x
```

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────┐
│                  INSTRUCTION QUICK REFERENCE                │
├──────────┬──────────────────────────────────────────────────┤
│ STACK    │ PSH v  LOD a  PUT a  POP  DRP                   │
│ ARITH    │ ADD  SUB  MUL  DIV  MOD                         │
│ BITWISE  │ AND  ORR  XOR  NOT  SHL  SHR                    │
│ MEMORY   │ MOV r,v  LDI a  STI a  LDB a  STB a            │
│ BRANCH   │ JMP  CMP a,b  JIE  JGT  JLT  HLT               │
│ CALLS    │ RUN label  RET  RTI  ENT  LEV                   │
│ SYSCALL  │ SYS  (set RS first)                             │
├──────────┼──────────────────────────────────────────────────┤
│ REGISTERS│ R0 R1 R2 R3 R4  RS RC RX RY FP                 │
├──────────┼──────────────────────────────────────────────────┤
│ SYSCALLS │ CHAR=1 CLEAR=2 DRAW=3 SLEEP=4 STRING=5          │
│          │ INPUT=6 RENDER=7 DISK_READ=8 DISK_WRITE=9       │
│          │ EXIT=99                                          │
├──────────┼──────────────────────────────────────────────────┤
│ DIRECTIVES│ .DATA  .TEXT  .STRING "..."  .DEFINE N V       │
│          │ %include file.asm   LABEL:                       │
└──────────┴──────────────────────────────────────────────────┘
```
