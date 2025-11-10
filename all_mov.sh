#!/usr/bin/env bash
shopt -s nullglob                   # ignore if no matches
shopt -s nocaseglob                 # match .mov or .MOV (case-insensitive)

for f in *.mov; do
  [[ -e "$f" ]] || continue         # skip if no files
  output="${f%.*}.mkv"
  echo "Converting: $f → $output"
  ffmpeg -i "$f" -c copy "$output"
done


