WHISPERX="python3 -m whisperx"

$WHISPERX "audio.wav" \
  --model large-v3 \
  --language en \
  --device cpu \
  --compute_type int8 \
  --diarize \
  --diarize_model "pyannote/speaker-diarization-3.1" \
  --vad_method pyannote \
  --hf_token "$HF_TOKEN" \
  --min_speakers 1 --max_speakers 1 \
  --output_format txt \
  --output_dir out


DIAR_DIR="$(dirname "$(find "$HOME/models/pyannote-sd3.1" -name config.yaml -print -quit)")"
echo "Using diarization model at: $DIAR_DIR"

whisperx "audio.wav" \
  --model large-v3 --language en \
  --device cpu --compute_type int8 \
  --diarize \
  --diarize_model "$DIAR_DIR" \
  --vad_method pyannote \
  --hf_token "$HF_TOKEN" \
  --min_speakers 1 --max_speakers 1 \
  --output_format txt --output_dir out

exit 
echo This should work
whisperx "audio.wav" \
  --model large-v3 \
  --language en \
  --device cpu \
  --compute_type int8 \
  --diarize \
  --diarize_model "$HOME/models/pyannote-sd3.1" \
  --vad_method pyannote \
  --hf_token "$HF_TOKEN" \
  --min_speakers 1 --max_speakers 1 \
  --output_format txt \
  --output_dir out


exit

echo Ideally this should work.

whisperx "audio.wav" \
  --model large-v3 --language en \
  --device cpu --compute_type int8 \
  --diarize --diarize_model "pyannote/speaker-diarization-3.1" \
  --vad_method pyannote \
  --hf_token "$HF_TOKEN" \
  --min_speakers 1 --max_speakers 1 \
  --output_format txt --output_dir out
