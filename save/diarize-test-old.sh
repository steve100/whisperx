
whisperx "audio.wav" \
  --model large-v3 --language en \
  --device cpu --compute_type int8 \
  --diarize --diarize_model "pyannote/speaker-diarization-3.1" \
  --vad_method pyannote \
  --hf_token "$HF_TOKEN" \
  --min_speakers 1 --max_speakers 1 \
  --output_format txt --output_dir out
