
file="$1"
export       name=$(basename "$file")
echo "$name"

export output_dir=$(dirname "$file")
echo "$output_dir"


whisperx "$1" \
  --model large-v3 \
  --language en \
  --device cpu \
  --compute_type int8 \
  --output_format txt \
  --output_dir $output_dir
