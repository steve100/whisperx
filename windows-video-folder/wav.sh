#!/bin/bash

# fmpeg -i "C:\Users\Steve\Videos\2025-05-11 21-39-04.mp4" -vn -acodec libmp3lame -q:a 2 "C:\Users\Steve\Videos\2025-05-11 21-39-04.mp3"


output=`echo $1 | sed 's/\.mkv$/.wav/'`

echo "input" $1
echo "output" $output

sleep 5
#Purpose

#Makes a bit-perfect copy of the existing audio track.
#Keeps original sampling rate (44.1 kHz, 48 kHz, etc.) and original channel count (stereo, 5.1, etc.).

#ffmpeg -i "$1" -map a  -c:a pcm_s16le  "$output"


#Purpose

#Optimized for speech/AI transcription (Whisper, WhisperX, Vosk, etc.)
#Produces smaller files, consistent sampling rate and mono channel.
#Guarantees model-compatible specs: 16-bit, mono, 16 kHz PCM.

ffmpeg -y -i "$1" -vn -ac 1 -ar 16000 "$output"
