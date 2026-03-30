#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: ./run.sh <program.asm>"
    exit 1
fi

INPUT_FILE=$1

BASENAME=$(basename "$INPUT_FILE" .asm)
OUTPUT_FILE="${BASENAME}.vm"

ASSEMBLER="./assembler"
VM="./vm"

echo "Assembling: $INPUT_FILE -> $OUTPUT_FILE"
$ASSEMBLER "$INPUT_FILE" "$OUTPUT_FILE"

if [ $? -eq 0 ]; then
    echo "Running Virtual Machine..."
    echo "-----------------------------------"
    
    # 5. Run the VM
    $VM "$OUTPUT_FILE"
    
    echo "-----------------------------------"
    echo "Execution finished."
else
    echo "Assembly failed. Halting process."
    exit 1
fi
