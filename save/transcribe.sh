#!/usr/bin/env bash
# Robust WhisperX CPU diarization script with diagnostics
# Usage: ./transcribe.sh "path/to/media.(mkv|mp4|wav|mp3)"

set -euo pipefail

# -------- Config --------
MODEL="large-v3"
LANG="en"
DEVICE="cpu"
COMPUTE_TYPE="int8"
OUTPUT_DIR="$(pwd)/out"
OUTPUT_FORMAT="txt"
DIARIZE_MODEL="pyannote/speaker-diarization-3.1"   # or "pyannote/speaker-diarization@2.1"

mkdir -p "$OUTPUT_DIR"

# -------- Args --------
if [ $# -lt 1 ]; then
  echo "❌ Error: provide an input media file."
  echo "Usage: ./transcribe.sh input.mkv"
  exit 1
fi
INPUT="$1"
if [ ! -f "$INPUT" ]; then
  echo "❌ Input not found: $INPUT"
  exit 1
fi

BASENAME="$(basename "${INPUT%.*}")"
OUT_TXT="${OUTPUT_DIR}/${BASENAME}.${OUTPUT_FORMAT}"
LOG_FILE="${OUTPUT_DIR}/${BASENAME}.log"

# -------- HF token --------
if [ -z "${HF_TOKEN:-}" ]; then
  read -p "Enter your Hugging Face token (starts with hf_): " USER_TOKEN
  export HF_TOKEN="$USER_TOKEN"
fi
export HUGGING_FACE_HUB_TOKEN="$HF_TOKEN"

# -------- Helpers --------
die() { echo -e "\n❌ $*"; echo "🔎 Last 50 log lines:"; tail -n 50 "$LOG_FILE" || true; exit 1; }

# -------- Show env & input info --------
echo "🧭 Working dir: $(pwd)"
echo "📄 Input: $INPUT"
echo "📤 Output dir: $OUTPUT_DIR"
echo "🪙 Using HF token: ${HF_TOKEN:0:6}… (hidden)"
command -v ffprobe >/dev/null 2>&1 && ffprobe -hide_banner -i "$INPUT" 2>/dev/null | head -n 8 || true

# -------- Verify HF token & gated access --------
echo "🔍 Verifying Hugging Face token & repo access..."
python3 - <<'PY' || exit 1
import os, sys
from huggingface_hub import whoami, model_info
tok = os.getenv("HF_TOKEN")
try:
    info = whoami(tok)
    print(f"✅ Authenticated as: {info.get('name') or info.get('fullname') or info.get('username')}")
    # Check access to gated diarization repo
    mi = model_info("pyannote/speaker-diarization-3.1", token=tok)
    print(f"✅ Access to pyannote/speaker-diarization-3.1 OK (sha: {mi.sha[:7]})")
except Exception as e:
    print("❌ Token invalid or repo access not granted.\n"
          "   Visit https://huggingface.co/pyannote/speaker-diarization-3.1 and click 'Access'.")
    print("   Error:", e)
    sys.exit(1)
PY

# -------- Locate WhisperX --------
WHISPERX_BIN="${WHISPERX_BIN:-}"
if [ -z "$WHISPERX_BIN" ]; then
  if command -v whisperx >/dev/null 2>&1; then
    WHISPERX_BIN="whisperx"
  else
    # Fallback to module form in the current Python
    WHISPERX_BIN="python3 -m whisperx"
  fi
fi
echo "🎯 WhisperX command: $WHISPERX_BIN"
$WHISPERX_BIN --version || true

# -------- Run WhisperX (log to file + console) --------
echo "🎧 Transcribing (this may take a while)…"
set +e
# Use 'tee' so you see progress and we also keep a log
$WHISPERX_BIN "$INPUT" \
  --model "$MODEL" \
  --language "$LANG" \
  --device "$DEVICE" \
  --compute_type "$COMPUTE_TYPE" \
  --diarize \
  --diarize_model "$DIARIZE_MODEL" \
  --vad_method pyannote \
  --hf_token "$HF_TOKEN" \
  --min_speakers 1 --max_speakers 1 \
  --output_format "$OUTPUT_FORMAT" \
  --output_dir "$OUTPUT_DIR" \
  --log-level info \
  | tee "$LOG_FILE"
EXIT_CODE=${PIPESTATUS[0]}
set -e

# -------- Evaluate result --------
if [ $EXIT_CODE -ne 0 ]; then
  die "WhisperX exited with code $EXIT_CODE."
fi

if [ ! -s "$OUT_TXT" ]; then
  # Some builds print transcript to stdout; capture fallback
  echo "ℹ️  No $OUT_TXT produced. Capturing stdout as fallback…" | tee -a "$LOG_FILE"
  set +e
  $WHISPERX_BIN "$INPUT" \
    --model "$MODEL" \
    --language "$LANG" \
    --device "$DEVICE" \
    --compute_type "$COMPUTE_TYPE" \
    --diarize \
    --diarize_model "$DIARIZE_MODEL" \
    --vad_method pyannote \
    --hf_token "$HF_TOKEN" \
    --min_speakers 1 --max_speakers 1 \
    --output_format "$OUTPUT_FORMAT" \
    --output_dir "$OUTPUT_DIR" \
    --log-level error \
    > "$OUT_TXT" 2>> "$LOG_FILE"
  FALLBACK_CODE=$?
  set -e
  [ $FALLBACK_CODE -ne 0 ] && die "Fallback capture failed (code $FALLBACK_CODE)."
fi

[ -s "$OUT_TXT" ] || die "Transcript file still missing."
echo "✅ Done. Transcript: $OUT_TXT"
echo "📝 Log: $LOG_FILE"

