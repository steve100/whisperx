#!/usr/bin/env python3
"""
Quick check for Hugging Face token and access to the
pyannote/speaker-diarization-3.1 model.
"""

import os
from huggingface_hub import whoami, model_info
from pyannote.audio import Pipeline

token = os.getenv("HF_TOKEN")
if not token:
    raise SystemExit("❌ No HF_TOKEN found in environment.  Run:\n  export HF_TOKEN='hf_xxx'")

print("🔍 Verifying token...")
try:
    info = whoami(token)
    print(f"✅ Logged in as: {info.get('name') or info.get('username')}")
except Exception as e:
    raise SystemExit(f"❌ Token rejected: {e}")

print("🔍 Checking access to pyannote/speaker-diarization-3.1...")
try:
    mi = model_info("pyannote/speaker-diarization-3.1", token=token)
    print(f"✅ Access confirmed (sha {mi.sha[:8]})")
except Exception as e:
    raise SystemExit(
        f"❌ You haven’t accepted access to the model.\n"
        f"Visit https://huggingface.co/pyannote/speaker-diarization-3.1 and click 'Access'.\n"
        f"Error: {e}"
    )

print("🔍 Attempting to load diarization pipeline (CPU)...")
try:
    pipe = Pipeline.from_pretrained("pyannote/speaker-diarization-3.1",
                                    use_auth_token=token)
    print("✅ Pipeline loaded successfully!")
except Exception as e:
    raise SystemExit(f"❌ Pipeline load failed:\n{e}")
