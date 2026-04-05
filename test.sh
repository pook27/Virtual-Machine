#!/bin/bash

# Ensure we have the latest compiled versions
echo "Building project..."
make clean > /dev/null
make > /dev/null || { echo "Build failed."; exit 1; }

TEST_DIR="tests"
PASSED=0
FAILED=0

echo -e "\nRunning Test Suite..."
echo "-----------------------------------"

# Find all .asm files in the tests directory
for ASM_FILE in "$TEST_DIR"/*.asm; do
    # Get the base name without extension
    BASENAME="${ASM_FILE%.*}"
    VM_FILE="${BASENAME}.bin"
    EXPECTED_FILE="${BASENAME}.expected"
    ACTUAL_FILE="${BASENAME}.actual"

    # 1. Assemble the file
    ./assembler "$ASM_FILE" "$VM_FILE" > /dev/null
    if [ $? -ne 0 ]; then
        echo "[FAIL] $ASM_FILE (Assembler Error)"
        ((FAILED++))
        continue
    fi

    # 2. Run the VM and capture the output
    ./cpu "$VM_FILE" --headless > "$ACTUAL_FILE"

    # 3. Compare with expected output
    if [ -f "$EXPECTED_FILE" ]; then
        if cmp -s "$EXPECTED_FILE" "$ACTUAL_FILE"; then
            echo "[PASS] $(basename "$ASM_FILE")"
            ((PASSED++))
            # Clean up actual file on pass
            rm "$ACTUAL_FILE"
        else
            echo "[FAIL] $(basename "$ASM_FILE") (Output mismatch)"
            echo "   Expected:"
            cat "$EXPECTED_FILE" | sed 's/^/     /'
            echo "   Actual:"
            cat "$ACTUAL_FILE" | sed 's/^/     /'
            ((FAILED++))
        fi
    else
        echo "[SKIP] $(basename "$ASM_FILE") (Missing .expected file)"
    fi
    
    # Clean up the compiled .vm file
    rm -f "$VM_FILE"
done

echo "-----------------------------------"
echo "Results: $PASSED Passed | $FAILED Failed"

if [ $FAILED -gt 0 ]; then
    exit 1
fi
