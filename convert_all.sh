#!/bin/env bash

# this script converts all (nested) .flac files from /input to opus files in /output
INPUT_DIR="/input"
OUTPUT_DIR="/output"
BITRATE=256

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

# copy all .jpg files from INPUT_DIR to OUTPUT_DIR preserving the directory structure
find "$INPUT_DIR" -type f -name "*.jpg" | while read -r JPG_FILE; do
    RELATIVE_PATH="${JPG_FILE#$INPUT_DIR/}"
    OUTPUT_FILE="$OUTPUT_DIR/$RELATIVE_PATH"
    OUTPUT_SUBDIR="$(dirname "$OUTPUT_FILE")"
    mkdir -p "$OUTPUT_SUBDIR"
    echo "Copying cover art '$JPG_FILE'"
    cp "$JPG_FILE" "$OUTPUT_FILE"
done

# now create playlists for all the opus files in the OUTPUT_DIR/Music/Playlists

mkdir -p "$OUTPUT_DIR/Playlists"
PLAYLIST_DIR="$OUTPUT_DIR/Music/Playlists"

# iterate through all the directories in OUTPUT_DIR/Music/Playlists
find "$PLAYLIST_DIR" -type d | while read -r DIR; do
    PLAYLIST_NAME="$(basename "$DIR").m3u"
    PLAYLIST_PATH="$OUTPUT_DIR/Playlists/$PLAYLIST_NAME"
    echo "Re-creating playlist '$PLAYLIST_PATH'"
    # delete the file if exists and re-create it
    rm -f "$PLAYLIST_PATH"
    touch "$PLAYLIST_PATH"
    # find all opus files in the directory and add them to the playlist
    find "$DIR" -type f -name "*.opus" | while read -r OPUS_FILE; do
        # strip "$OUTPUT_DIR" from the beginning of the path
        OPUS_FILE="${OPUS_FILE#$OUTPUT_DIR/}"
        echo "../$OPUS_FILE" >> "$PLAYLIST_PATH"
        echo "../$OPUS_FILE"
    done
    echo "\n"
done

# do the same, but in the Music directory itself


mkdir -p "$OUTPUT_DIR/Music/m3us"
PLAYLIST_DIR="$OUTPUT_DIR/Music/Playlists"

# iterate through all the directories in OUTPUT_DIR/Music/Playlists
find "$PLAYLIST_DIR" -type d | while read -r DIR; do
    PLAYLIST_NAME="$(basename "$DIR").m3u"
    PLAYLIST_PATH="$OUTPUT_DIR/Music/m3us/$PLAYLIST_NAME"
    echo "Re-creating playlist '$PLAYLIST_PATH'"
    # delete the file if exists and re-create it
    rm -f "$PLAYLIST_PATH"
    touch "$PLAYLIST_PATH"
    # find all opus files in the directory and add them to the playlist
    find "$DIR" -type f -name "*.opus" | while read -r OPUS_FILE; do
        # strip "$OUTPUT_DIR/Music" from the beginning of the path
        OPUS_FILE="${OPUS_FILE#$OUTPUT_DIR/Music/}"
        echo "../$OPUS_FILE" >> "$PLAYLIST_PATH"
        echo "../$OPUS_FILE"
    done
    echo "\n"
done

echo "we're out"
