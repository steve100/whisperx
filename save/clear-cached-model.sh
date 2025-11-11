rm -rf ~/.cache/huggingface/hub/models--pyannote--speaker-diarization-3.1
rm -rf ~/.cache/huggingface/hub/models--pyannote--speaker-diarization


mkdir -p ~/models/pyannote-sd3.1

python3 - <<'PY'
import os
from huggingface_hub import snapshot_download

tok = os.environ.get("HF_TOKEN")

print ("token:") ; print (tok)

assert tok and tok.startswith("hf_"), "Set HF_TOKEN first"

path = snapshot_download(
    repo_id="pyannote/speaker-diarization-3.1",
    token=tok,
    local_dir=os.path.expanduser("~/models/pyannote-sd3.1"),
    local_dir_use_symlinks=False
)
print("✅ Downloaded to:", path)
PY


