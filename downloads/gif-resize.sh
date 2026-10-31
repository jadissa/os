#!/bin/bash

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <input.gif> <target_size>"
    echo "Example: $0 animation.gif 2M  (Use 'K' for Kilobytes, 'M' for Megabytes)"
    exit 1
fi

INPUT_FILE="$1"
TARGET_STR="$2"

# 1. Validation & Setup
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found."
    exit 1
fi

# Dissect path to preserve original untouched and build the clean output name
DIR=$(dirname "$INPUT_FILE")
FILENAME=$(basename "$INPUT_FILE")
BASENAME="${FILENAME%.*}"
EXTENSION="${FILENAME##*.}"
FINAL_OUTPUT="${DIR}/${BASENAME}_compressed.${EXTENSION}"

# Convert target size parameter (e.g., 500K, 2M) into bytes
if [[ "$TARGET_STR" =~ ^([0-9]+)[M|m]$ ]]; then
    TARGET_SIZE=$(( ${BASH_REMATCH[1]} * 1024 * 1024 ))
elif [[ "$TARGET_STR" =~ ^([0-9]+)[K|k]$ ]]; then
    TARGET_SIZE=$(( ${BASH_REMATCH[1]} * 1024 ))
elif [[ "$TARGET_STR" =~ ^([0-9]+)$ ]]; then
    TARGET_SIZE=${BASH_REMATCH[1]}
else
    echo "Error: Invalid target size format. Use e.g., 2M, 500K, or raw bytes."
    exit 1
fi

# Check if the original is already within bounds
CURRENT_SIZE=$(stat -f%z "$INPUT_FILE")
if [ "$CURRENT_SIZE" -le "$TARGET_SIZE" ]; then
    echo "Original file is already smaller than or equal to the target size."
    FINAL_OUTPUT="${DIR}/${BASENAME}_copy.${EXTENSION}"
    cp "$INPUT_FILE" "$FINAL_OUTPUT"
    echo "Saved a copy to: $FINAL_OUTPUT"
    exit 0
fi

# Create a secure temporary file to evaluate intermediate compression steps
TMP_OUT=$(mktemp /tmp/gifcomp.XXXXXX)

# Ensure temporary files are cleared even if the script is interrupted
trap 'rm -f "$TMP_OUT"' EXIT

echo "Target size: $TARGET_STR ($TARGET_SIZE bytes)"
echo "Optimizing while preserving animation loops..."

# --- STRATEGY 1: Color reduction (Max quality fallback, steps down gradually) ---
# --loop enforces the animation loops indefinitely, matching typical original behavior.
for colors in 256 220 180 140 100 64 32; do
    gifsicle -O3 --loop --colors "$colors" "$INPUT_FILE" -o "$TMP_OUT"
    CURRENT_SIZE=$(stat -f%z "$TMP_OUT")
    if [ "$CURRENT_SIZE" -le "$TARGET_SIZE" ]; then
        cp "$TMP_OUT" "$FINAL_OUTPUT"
        echo "Success! Compressed using $colors colors."
        echo "Saved to: $FINAL_OUTPUT ($((CURRENT_SIZE / 1024)) KB)"
        exit 0
    fi
done

# --- STRATEGY 2: Frame rate reduction (Keep 64 colors, drop alternating frames) ---
# '#0-derived/2' drops every other frame while adapting frame delays to keep correct animation speed.
echo "Color reduction alone insufficient. Dropping alternating frames..."
gifsicle -O3 --loop --colors 64 "$INPUT_FILE" '#0-derived/2' -o "$TMP_OUT"
CURRENT_SIZE=$(stat -f%z "$TMP_OUT")
if [ "$CURRENT_SIZE" -le "$TARGET_SIZE" ]; then
    cp "$TMP_OUT" "$FINAL_OUTPUT"
    echo "Success! Compressed by dropping frames."
    echo "Saved to: $FINAL_OUTPUT ($((CURRENT_SIZE / 1024)) KB)"
    exit 0
fi

# --- STRATEGY 3: Dimensional Scaling (Maintains dropped frames, scales down resolution) ---
echo "Dropping frames insufficient. Progressively downscaling dimensions..."
for scale in 0.9 0.8 0.7 0.6 0.5 0.4 0.3; do
    gifsicle -O3 --loop --colors 64 --scale "$scale" "$INPUT_FILE" '#0-derived/2' -o "$TMP_OUT"
    CURRENT_SIZE=$(stat -f%z "$TMP_OUT")
    if [ "$CURRENT_SIZE" -le "$TARGET_SIZE" ]; then
        cp "$TMP_OUT" "$FINAL_OUTPUT"
        SCALE_PCT=$(echo "$scale * 100" | bc | cut -d. -f1)
        echo "Success! Compressed by downscaling dimensions to ${SCALE_PCT}%."
        echo "Saved to: $FINAL_OUTPUT ($((CURRENT_SIZE / 1024)) KB)"
        exit 0
    fi
done

# --- FALLBACK: Max compression profile if target threshold is strictly missed ---
gifsicle -O3 --loop --colors 32 --scale 0.25 "$INPUT_FILE" '#0-derived/2' -o "$TMP_OUT"
cp "$TMP_OUT" "$FINAL_OUTPUT"
CURRENT_SIZE=$(stat -f%z "$FINAL_OUTPUT")
echo "Warning: Target size could not be fully met without ruining the image."
echo "Best-effort threshold version saved to: $FINAL_OUTPUT ($((CURRENT_SIZE / 1024)) KB)"