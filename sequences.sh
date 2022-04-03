#! /bin/bash

# Source folder with animation frames as individual files:
IN_DIR="${1}"
if [[ -z "${IN_DIR}" ]]; then
  echo "Input directory not specified - pass it as first argument:"
  echo "`basename $0` path/to/input/dir"
  exit 1
fi
if ! [[ -d "${IN_DIR}" ]]; then
  echo "Input directory ${IN_DIR} does not exist"
  exit 1
fi


# number of frames in each animation:
FRAMES=10
# Copy $FRAMES files at a time, create the animation from them
# Needs to match what the animation script expects as input:
ANIM_DIR="${HOME}/Pictures/src"

# make sure that the animation script is exists:
script_name=$0
script_full_path=$(dirname "$0")
ANIMATION_SCRIPT="${script_full_path}/animate.sh"
if [ ! -f "${ANIMATION_SCRIPT}" ]; then
  echo "animation script ${ANIMATION_SCRIPT} not found - exiting."
  exit 1
fi

# Create an auto-deleted (when this scipt ends or is killed) temporary dir
TEMPD=$(mktemp -d)
if [ ! -e "$TEMPD" ]; then
    >&2 echo "Failed to create temp directory"
    exit 1
fi
trap "exit 1"           HUP INT PIPE QUIT TERM
trap 'rm -rf "$TEMPD"'  EXIT

# make a copy of the input directory, to not delete source:
if ! `cp "${IN_DIR}/"*.* "${TEMPD}"`; then
  echo 'Failed to copy files into temporary directory'
  exit 1
fi

# Copy $FRAMES files at a time, call into separate script to create the animation
while [ -n "$(ls -A ${TEMPD})" ]; do
  # Clear up animation directory, to avoid using existing files as frames:
  rm "${ANIM_DIR}"/* 2>/dev/null
  # Copy next $FRAMES files
  find "${TEMPD}" -maxdepth 1 -type f -iname '*.jpg' -print | sort | head -n $FRAMES | xargs -I _ mv _ "${ANIM_DIR}"
  $ANIMATION_SCRIPT || echo "${ANIMATION_SCRIPT} failed, continuing anyway"
done
