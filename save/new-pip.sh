#!/usr/bin/env bash
set -euo pipefail

python -V 

echo "==> Installing torch/torchaudio (CPU wheels) from PyTorch index…"
python -m pip install -U torch torchaudio \
  --index-url https://download.pytorch.org/whl/cpu

echo "==> Installing huggingface-hub (<1.0) and pyannote.audio (3.1.x)…"
python -m pip install -U "huggingface-hub>=0.34.0,<1.0" "pyannote.audio>=3.1,<3.2"

echo "==> Versions:"
python - << 'PY'
import torch, torchaudio, huggingface_hub, pyannote.audio
print("torch:", torch.__version__)
print("torchaudio:", torchaudio.__version__)
print("huggingface_hub:", huggingface_hub.__version__)
print("pyannote.audio:", pyannote.audio.__version__)
PY

