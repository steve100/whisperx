
# now all commands use that venv
python -V
which python

python -m pip install -U pip wheel setuptools

# keep torch/torchaudio matched on 2.8.*
python -m pip install --no-cache-dir --force-reinstall \
  torch==2.8.0 torchaudio==2.8.0 \
  --index-url https://download.pytorch.org/whl/cpu

exit

echo sleeping ; sleep 5


# hub < 1.0 for pyannote compatibility
python -m pip install --no-cache-dir --force-reinstall "huggingface-hub>=0.34.0,<1.0"
echo sleeping ; sleep 5

# upgrade pyannote.audio into the range WhisperX wants
python -m pip install --no-cache-dir --upgrade "pyannote.audio>=3.3.2,<3.5"
echo sleeping ; sleep 5

# (optional) refresh WhisperX to current
#python -m pip install --no-cache-dir -U "git+https://github.com/m-bain/whisperx.git"
pip install git+https://github.com/m-bain/whisperx.git

echo sleeping ; sleep 5



echo Verify:

python - << 'PY'
import torch, torchaudio, huggingface_hub, pyannote.audio
print("torch:", torch.__version__)
print("torchaudio:", torchaudio.__version__)
print("huggingface_hub:", huggingface_hub.__version__)
print("pyannote.audio:", pyannote.audio.__version__)
PY

echo "do not know why this helps"
pip install git+https://github.com/m-bain/whisperx.git
