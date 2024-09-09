#! /bin/bash

# rsyncs specific set of subdirectories of $source to $destination

set -ex

declare -r destination="/Volumes/data-1/Photos backup"
if [[ ! -d "${destination}" ]]; then
  echo "Destination directory doesn't exist: ${destination}"
  exit 1
fi

declare -r source="${HOME}/Drive"
if [[ ! -d "${source}" ]]; then
  echo "Source directory doesn't exist: ${source}"
  exit 1
fi

# create combined array of all directories to rsync
declare -a dirs_non_sequential=("1980s" "1990s" "1995" "1998")

# combining these two doesn't work:
declare -a years
years=({2000..2024})

# merge arrays
declare -a dirs=( "${dirs_non_sequential[@]}" "${years[@]}")

for dir in "${dirs[@]}"; do
  rsync -avrm -W --delete "${source}/${dir}/" "${destination}/${dir}/"
done
