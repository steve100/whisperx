#!/usr/bin/env bash
#
# WhisperX transcription script (CPU mode, diarization enabled)
# Usage:
#   ./transcribe.sh "path/to/video_or_audio_file"
#
# Example:
#   ./transcribe.sh "1-Mindset-to-scale-your-business-2025.mkv"

set -e

source ~/whisperx-venv/bin/activate

# ===== CONFIGURATION =====
MODEL="large-v3"
LANG="en"
DEVICE="cpu"
COMPUTE_TYPE="int8"
OUTPUT_FORMAT="txt"

# ===== CHECK ARGUMENT =====
if [ -z "$1" ]; then
  echo "❌ Error: please provide an input media file."
  echo "Usage: ./transcribe.sh input.mkv"
  exit 1
fi
INPUT="$1"

# ===== HF TOKEN SETUP =====
if [ -z "$HF_TOKEN" ]; then
  echo "⚙️  Hugging Face token not found."
  read -p "Enter your HF token (starts with hf_): " USER_TOKEN
  export HF_TOKEN="$USER_TOKEN"
fi

# ===== RUN WHISPERX =====
echo "🎧 Starting WhisperX transcription..."
whisperx "$INPUT" \
  --model "$MODEL" \
  --language "$LANG" \
  --device "$DEVICE" \
  --compute_type "$COMPUTE_TYPE" \
  --diarize \
  --hf_token "$HF_TOKEN" \
  --align_output \
  --output_format "$OUTPUT_FORMAT"

echo "✅ Transcription complete!"
echo "🗂️  Output saved as: $(basename "${INPUT%.*}").${OUTPUT_FORMAT}"

