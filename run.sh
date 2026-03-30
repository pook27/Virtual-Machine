#!/bin/bash
if [ "$#" -ne 1 ]; then
    echo "Usage: ./run.sh <program.asm>"
    exit 1
fi

# compile binaries if they don't exist
if [ ! -f "./assembler" ]; then
    echo "Assembler not found. Compiling..."
    gcc assembler.c -o assembler
    if [ $? -ne 0 ]; then
        echo "Failed to compile assembler."
        exit 1
    fi
fi

if [ ! -f "./cpu" ]; then
    echo "VM not found. Compiling..."
    gcc cpu.c -o cpu -lm
    if [ $? -ne 0 ]; then
        echo "Failed to compile VM."
        exit 1
    fi
fi

INPUT_FILE=$1
BASENAME=$(basename "$INPUT_FILE" .asm)
OUTPUT_FILE="${BASENAME}.vm"
ASSEMBLER="./assembler"
VM="./cpu"

echo "Assembling: $INPUT_FILE -> $OUTPUT_FILE"
$ASSEMBLER "$INPUT_FILE" "$OUTPUT_FILE"

if [ $? -eq 0 ]; then
    echo "Running Virtual Machine..."
    echo "-----------------------------------"
    $VM "$OUTPUT_FILE"
    echo "-----------------------------------"
    echo "Execution finished."
else
    echo "Assembly failed. Halting process."
    exit 1
fi
