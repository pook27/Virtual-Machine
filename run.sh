#!/bin/bash

if [ "$#" -lt 1 ]; then
    echo "Usage: ./run.sh <program.asm> [--debug]"
    exit 1
fi

INPUT_FILE=$1
DEBUG_FLAG=$2

BASENAME=$(basename "$INPUT_FILE" .asm)
OUTPUT_FILE="${BASENAME}.vm"

# 1. Compile everything using the Makefile
echo "Running Make..."
make || { echo "Build failed."; exit 1; }

# 2. Run the Assembler
echo "Assembling: $INPUT_FILE -> $OUTPUT_FILE"
./assembler "$INPUT_FILE" "$OUTPUT_FILE"

if [ $? -eq 0 ]; then
    echo "Running Virtual Machine..."
    echo "-----------------------------------"
    
    # 3. Run the VM, passing the debug flag if it exists
    ./cpu "$OUTPUT_FILE" $DEBUG_FLAG
    
    echo -e "\n-----------------------------------"
    echo "Execution finished."
else
    echo "Assembly failed. Halting process."
    exit 1
fi
