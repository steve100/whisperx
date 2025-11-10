#!/usr/bin/env bash
set -euo pipefail

echo "woot"
sleep 5

in="${1:-}"
out="${2:-${in%.*}.mkv}"

if [[ -z "$in" || ! -f "$in" ]]; then
  echo "Usage: $0 input.mov [output.mkv]" >&2
  exit 1
fi

if [[ -e "$out" ]]; then
  echo "Refusing to overwrite existing file: $out" >&2
  exit 1
fi

echo "🔎 Checking rotation for: $in"

# 1) Try rotate tag
rot="$(ffprobe -v error -select_streams v:0 \
      -show_entries stream_tags=rotate \
      -of default=nk=1:nw=1 "$in" 2>/dev/null || true)"

# 2) If empty, try side-data JSON and grep the "rotation" field
if [[ -z "${rot}" ]]; then
  rot="$(ffprobe -v error -select_streams v:0 \
        -show_entries stream=side_data_list \
        -of json "$in" 2>/dev/null \
        | grep -oE '"rotation"\s*:\s*-?[0-9]+' | head -n1 \
        | grep -oE '-?[0-9]+' || true)"
fi

# Normalize: keep only first integer (handles stray commas or blanks)
rot="$(printf '%s' "${rot:-0}" | grep -oE '-?[0-9]+' | head -n1 || true)"
rot="${rot:-0}"

vf=""
case "$rot" in
  0|"")      echo "➡️  No rotation detected (rot=$rot)";;
  90|-270)   echo "➡️  Will rotate 90° clockwise";            vf="transpose=1";;
  -90|270)   echo "➡️  Will rotate 90° counter-clockwise";     vf="transpose=2";;
  180|-180)  echo "➡️  Will rotate 180°";                     vf="transpose=2,transpose=2";;
  *)         echo "⚠️  Unrecognized rotation '$rot' — not rotating"; vf="";;
esac

if [[ -z "$vf" ]]; then
  # Lossless remux. Drop data/attachments so MKV muxer is happy.
  ffmpeg -n -hide_banner -loglevel error -stats -noautorotate \
    -i "$in" -map 0 -map -0:d -map -0:t -c copy "$out"
else
  # Apply rotation; clear tag; keep audio; drop data/attachments.
  ffmpeg -n -hide_banner -loglevel error -stats -noautorotate \
    -i "$in" \
    -vf "$vf,setsar=1" -metadata:s:v:0 rotate=0 \
    -c:v libx264 -pix_fmt yuv420p -preset medium -crf 20 \
    -c:a copy \
    -map 0 -map -0:d -map -0:t \
    "$out"
fi

echo "✅ Output: $out"
