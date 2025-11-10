
export p=/mnt/c/Users/Steve/Videos/extras/
whisperx "$1" \
  --model large-v3 \
  --language en \
  --diarize \
  --device cpu \
  --compute_type int8 \
  --hf_token $HF_TOKEN \
  --output_format txt \
  --align_output

