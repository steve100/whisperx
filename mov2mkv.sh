#!/usr/bin/env bash
set -euo pipefail

filename="${1:-}"

if [[ -z "$filename" ]]; then
  echo "Usage: $0 file.mov"
  exit 1
fi

# Check extension via case/esac and build the output name
case "${filename##*.}" in
  mov|MOV)
    output="${filename%.*}.mkv"
    ;;
  *)
    echo "Not a .mov file: $filename"
    exit 1
    ;;
esac

echo "Input : $filename"
echo "Output: $output"



ffmpeg -i $filename -c copy $output
