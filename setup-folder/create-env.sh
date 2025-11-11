# Using Standard Python create a virtual environment
python3 -m venv ~/whisperx-venv

#hack?
chmod +x ~/whisperx-venv/bin/activate

# little hard coding anyone?
 source ~/whisperx-venv/bin/activate


export VENV="~/whisperx-venv"
source "$VENV/bin/activate"

# now all commands use that venv
python -V
which python

echo sleeping 5
sleep 5
python -m pip install -U pip wheel setuptools

