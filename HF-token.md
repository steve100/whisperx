## Get a hugging face token for diarize
Step 1. Get your Hugging Face token

Go to https://huggingface.co/settings/tokens

###Click “New token”
  Give it a name (e.g. whisperx)

  Set Role → Read (that’s all you need)
  Although for my first token I got write 

###Copy the token — it looks like:
hf_LrG1aBcD2eF3gHijklMnOpQrStUvWxYzAB

#### Option A: Environment variable (recommended)
export HF_TOKEN="hf_yourtokenhere"
export HUGGING_FACE_HUB_TOKEN="$HF_TOKEN"

To make it permanent, add that to your ~/.bashrc or ~/.bash_profile.


#### Option B: WhisperX flag
You can also include it directly in the command: