#!/bin/bash
# =============================================================
# VM Build Pipeline
# Usage:
#   ./build.sh [program]          — standalone (direct cpu run)
#   ./build.sh [program] --os     — full OS (boot → kernel → program)
#   ./build.sh [program] --headless  — standalone, no window
# =============================================================
set -e

PROGRAM=""
OS_MODE=false
HEADLESS=""

for arg in "$@"; do
    case "$arg" in
        --os)       OS_MODE=true ;;
        --headless) HEADLESS="--headless" ;;
        -*)         echo "Unknown flag: $arg"; exit 1 ;;
        *)          PROGRAM="$arg" ;;
    esac
done

PROGRAM="${PROGRAM:-dvd}"
ASM_FILE="programs/${PROGRAM}.asm"

# --- Validate program ---
if [ ! -f "$ASM_FILE" ]; then
    echo "Error: No such program: $ASM_FILE"
    echo ""
    echo "Available programs:"
    for f in programs/*.asm; do
        name=$(basename "$f" .asm)
        case "$name" in boot|kernel) continue ;; esac
        echo "  $name"
    done
    exit 1
fi

echo "┌──────────────────────────────────────┐"
echo "│  VM Build Pipeline                   │"
if $OS_MODE; then
echo "│  Mode: Full OS  │  Program: $PROGRAM"
else
echo "│  Mode: Standalone  │  Program: $PROGRAM"
fi
echo "└──────────────────────────────────────┘"
echo ""

# Step 1: Build tools
printf "[ 1/5 ] Building tools...       "
make -s all
echo "done"

# Step 2: Generate font
printf "[ 2/5 ] Generating font...      "
./font_maker > /dev/null
echo "done"

# Step 3: Assemble
printf "[ 3/5 ] Assembling...           "
if $OS_MODE; then
    ./assembler programs/boot.asm   boot.bin
    ./assembler programs/kernel.asm kernel.bin 4096
    ./assembler "$ASM_FILE" "${PROGRAM}.bin" 20000
else
    ./assembler "$ASM_FILE" "${PROGRAM}.bin"
fi
echo "done"

# Step 4: Build disk image (OS mode only)
if $OS_MODE; then
    printf "[ 4/5 ] Building disk image...  "
    ./imager drive.img boot.bin kernel.bin font.bin "${PROGRAM}.bin" 2>&1 | \
        grep -v "^$" | sed 's/^/         /'
    echo ""
else
    echo "[ 4/5 ] Disk image skipped (standalone mode)"
fi

# Step 5: Launch
echo "[ 5/5 ] Launching: $PROGRAM"
echo ""

if $OS_MODE; then
    ./cpu $HEADLESS
else
    ./cpu "${PROGRAM}.bin" $HEADLESS
fi
