# not recently tested.

pip install git+https://github.com/m-bain/whisperx.git

pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
pip install pyannote.audio

# yet doesn't install hugging_face_cli 
pip install -U "huggingface_hub[cli]"


#recomendation one
pip install -U "pyannote.audio>=3.1,<3.2" "huggingface_hub>=0.23" \
             "torch" "torchaudio" --index-url https://download.pytorch.org/whl/cpu

# recomendation two 
#pip install "huggingface-hub>=0.34.0,<1.0" --force-reinstall

# last recomendation
pip install "pyannote.audio>=3.1,<3.2" "huggingface-hub>=0.34.0,<1.0" "torch" "torchaudio" --index-url https://download.pytorch.org/whl/cpu

pip install "huggingface-hub>=0.34.0,<1.0" --force-reinstall

#check
pip show huggingface-hub | grep Version
whisperx --version

echo confirm
python3 - << 'PY'
import pyannote.audio, torch, huggingface_hub
print("pyannote.audio:", pyannote.audio.__version__)
print("torch:", torch.__version__)
print("huggingface_hub:", huggingface_hub.__version__)
PY

echo "check again"
./new-new.sh
