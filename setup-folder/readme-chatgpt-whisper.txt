When using WhisperX with diarization (--diarize), it relies on Hugging Face’s pyannote.audio models to separate speakers — and those models require a free Hugging Face access token.

Here’s exactly how to set it up under WSL (no CUDA, CPU-only) 👇

🪪 Step 1. Get your Hugging Face token

Go to https://huggingface.co/settings/tokens

Click “New token”

Give it a name (e.g. whisperx)

Set Role → Read (that’s all you need)

Copy the token — it looks like:

hf_LrG1aBcD2eF3gHijklMnOpQrStUvWxYzAB

⚙️ Step 2. Add your token in WSL
Option A: Environment variable (recommended)
export HF_TOKEN="hf_yourtokenhere"


To make it permanent, add that line to your ~/.bashrc or ~/.bash_profile.

Option B: WhisperX flag

You can also include it directly in the command:

whisperx "your-business-training-2025.mkv" \
  --model large-v3 \
  --language en \
  --diarize \
  --device cpu \
  --compute_type int8 \
  --hf_token $HF_TOKEN \
  --output_format txt \
  --align_output

💡 Why this matters



ps now using a newer model 
While logged in to your Hugging Face account, open and click “Agree / Access”:
https://huggingface.co/pyannote/speaker-diarization-3.1

(If you prefer the older pipeline: https://huggingface.co/pyannote/speaker-diarization
 — but WhisperX is now defaulting to 3.1.)

 - was using
    The diarization step downloads and uses:
    pyannote/speaker-diarization@2.1


This model is gated — Hugging Face requires you to accept its terms the first time:
👉 Visit https://huggingface.co/pyannote/speaker-diarization

and click “Access repository” before running WhisperX.

✅ After setup

You’ll get output like:

[00:00:03] Speaker 1: Welcome to the training.
[00:02:45] Speaker 1: The mindset to scale is...

---------------
4) Run WhisperX with explicit model + token

Two reliable options:

A) Use the 3.1 pipeline (recommended)
whisperx "audio.wav" \
  --model large-v3 \
  --language en \
  --device cpu \
  --compute_type int8 \
  --diarize \
  --diarize_model "pyannote/speaker-diarization-3.1" \
  --vad_method pyannote \
  --hf_token "$HF_TOKEN" \
  --min_speakers 1 --max_speakers 1 \
  --output_format txt --output_dir .

B) Fall back to the older (2.1) pipeline

If you prefer the older model (sometimes lighter on CPU):

whisperx "audio.wav" \
  --model large-v3 \
  --language en \
  --device cpu \
  --compute_type int8 \
  --diarize \
  --diarize_model "pyannote/speaker-diarization@2.1" \
  --vad_method pyannote \
  --hf_token "$HF_TOKEN" \
  --min_speakers 1 --max_speakers 1 \
  --output_format txt --output_dir .


(You must also accept access for that repo once in the browser.)

6) Last-resort workaround (no diarization)

If you only need timestamps and there’s truly one speaker, you can temporarily skip diarization (until the token issue is sorted):

whisperx "audio.wav" \
  --model large-v3 --language en \
  --device cpu --compute_type int8 \
  --output_format txt --output_dir .

  echo not finding the cli 
huggingface-cli --version



To confirm the login works

Run:

python - << 'PY'
from huggingface_hub import whoami
print(whoami())
PY


If it prints your username and orgs, the token is valid and visible to WhisperX.


Ideally this should work.

whisperx "audio.wav" \
  --model large-v3 --language en \
  --device cpu --compute_type int8 \
  --diarize --diarize_model "pyannote/speaker-diarization-3.1" \
  --vad_method pyannote \
  --hf_token "$HF_TOKEN" \
  --min_speakers 1 --max_speakers 1 \
  --output_format txt --output_dir out