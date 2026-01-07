#!/bin/env bash

# this script converts all (nested) .flac files from /input to opus files in /output
INPUT_DIR="/input"
OUTPUT_DIR="/output"
BITRATE=224

FILE_COUNT=$(find "$INPUT_DIR" -type f -size +100k -name "*.flac" | wc -l)
echo "Found $FILE_COUNT FLAC files to convert."

FILE_NO=0


find "$INPUT_DIR" -type f -size +100k -name "*.flac" | while read -r FLAC_FILE; do
    # Determine the relative path of the FLAC file with respect to the input directory

    FILE_NO=$((FILE_NO + 1))
    # every 100 files, print progress
    if (( FILE_NO % 100 == 0 )); then
        PERCENT=$(( FILE_NO * 100 / FILE_COUNT ))
        echo "$PERCENT%: $FILE_NO / $FILE_COUNT files."
        # print progress percentage
    fi

    RELATIVE_PATH="${FLAC_FILE#$INPUT_DIR/}"
    
    # Determine the output directory and create it if it doesn't exist
    OUTPUT_SUBDIR="$(dirname "$OUTPUT_DIR/$RELATIVE_PATH")"
    mkdir -p "$OUTPUT_SUBDIR"
    
    # Determine the output file name by replacing .flac with .opus
    OUTPUT_FILE="$OUTPUT_SUBDIR/$(basename "${RELATIVE_PATH%.flac}.opus")"

    # check if the file already exists
    if [ -f "$OUTPUT_FILE" ]; then
        # echo "Skipping '$FLAC_FILE' as '$OUTPUT_FILE' already exists."
        continue
    fi

    echo "\nConverting '$FLAC_FILE'"
    
    # Convert the FLAC file to OPUS format using opusenc
    opusenc --no-phase-inv --downmix-stereo --bitrate "$BITRATE" "$FLAC_FILE" "$OUTPUT_FILE"
done


echo "we're out"
