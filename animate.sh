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

# Find last numbered animated image, continue with next number:
FILENAME=$(ls -t -1 $OUTPUT_DIR | head -1 | sed s/."${EXT}"//)
if [ ${FILENAME} ]; then
  FILENAME="${FILENAME%.*}"
else
	FILENAME="0"
fi
NEW_FILENAME="$(($FILENAME + 1)).${EXT}"

# For some reason, the file we want to write already exists - error.
if [ -e $NEW_FILENAME ]; then
	echo "file ${NEW_FILENAME} already exists, this is a bug."
	exit 1
fi

# Check that imagemagick is installed:
if ! $(which magick  >/dev/null); then
	echo "magick is not found or not in path. Please install it first."
	exit 1
fi

# Lowercase all filenames:
for f in $INPUT_DIR/*; do
	mv $f "$(echo ${f} | tr '[:upper:]' '[:lower:]')"
done

#  -resize $SIZE
magick -delay $DELAY -dispose None -loop 0 -quality $QUALITY "${INPUT_DIR}"/*.jpg "${OUTPUT_DIR}/${NEW_FILENAME}" && rm "${INPUT_DIR}"/*.jpg
