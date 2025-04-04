#! /bin/bash

# Creates an animation (webp) from all files in INPUT_DIR. Deletes input files when successful.
# The created animation will have a unique name, using next free number in output directory.
# e.g. if 7.webp exists, it will create 8.webp as output

# TODO: change these to parameters passed to the script:
INPUT_DIR=~/Pictures/src
OUTPUT_DIR=~/Pictures/out
SIZE="100%"
EXT="webp"
QUALITY=80
DELAY=20

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Check that imagemagick is installed:
if ! $(which magick >/dev/null); then
    echo "magick is not found or not in path. Please install it first."
    exit 1
fi

# Lowercase all filenames (important for consistency)
# Using a loop that handles potential errors and spaces in filenames
for f in "$INPUT_DIR"/*; do
    # Check if it's a file before trying to rename
    if [ -f "$f" ]; then
        # Get directory and filename separately
        dir=$(dirname "$f")
        filename=$(basename "$f")
        # Convert filename to lowercase
        new_filename_lower=$(echo "$filename" | tr '[:upper:]' '[:lower:]')
        # Rename only if the name changes
        if [ "$filename" != "$new_filename_lower" ]; then
            mv -- "$f" "$dir/$new_filename_lower"
        fi
    fi
done


# Determine output file name:

# Find the first JPEG file to determine the base name
# Use find for better handling of filenames and ensure we only get files
first_jpg=$(find "$INPUT_DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' \) -print | sort | head -n 1)
if [ -z "$first_jpg" ]; then
    echo "No JPEG files found in ${INPUT_DIR}"
    exit 1
fi

# Extract base name from the first found jpg file
# Removes extension (.jpg or .jpeg) and trailing sequence numbers (-digits)
base_name=$(basename "$first_jpg")
base_name=${base_name%.*} # Remove extension (shortest match)
base_name=$(echo "$base_name" | sed -E 's/-[0-9]+$//') # Remove trailing -digits

# Find last numbered animated image, continue with next number:
target_base_path="${OUTPUT_DIR}/${base_name}"
output_filename="${target_base_path}.${EXT}"
counter=1

# Check if the base filename exists, and if so, find the next available number
while [ -e "$output_filename" ]; do
    output_filename="${target_base_path}-${counter}.${EXT}"
    counter=$((counter + 1))
done

magick -delay $DELAY -dispose None -loop 0 -quality $QUALITY -dispose None "${INPUT_DIR}"/*.jpg "${output_filename}" && rm "${INPUT_DIR}"/*.jpg
