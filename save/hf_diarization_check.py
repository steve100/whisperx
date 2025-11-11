#!/usr/bin/env python3
"""
Robust Hugging Face + pyannote diarization auth/compat check.

What it does:
1) Prints package versions and key env vars
2) Verifies HF token and access to pyannote/speaker-diarization-3.1
3) Attempts a local snapshot_download of the model into ~/models/pyannote-sd3.1
4) Loads Pipeline from the local path (bypasses hub timing/gating flakiness)
5) If 3.1 fails, tries older pyannote/speaker-diarization@2.1 as fallback
"""

import os, sys, traceback, shutil
from pathlib import Path

def print_header(title):
    print("\n" + "="*len(title))
    print(title)
    print("="*len(title))

# --- 0) Show environment info
print_header("Environment")
print("Python:", sys.version.replace("\n"," "))
for var in ["HF_TOKEN", "HUGGING_FACE_HUB_TOKEN", "HF_HUB_OFFLINE", "TRANSFORMERS_OFFLINE"]:
    v = os.getenv(var)
    print(f"{var}:", (v[:10] + "…") if v else "(not set)")

def safe_ver(modname):
    try:
        mod = __import__(modname)
        ver = getattr(mod, "__version__", "(no __version__)")
        print(f"{modname}: {ver}")
        return ver
    except Exception as e:
        print(f"{modname}: import FAILED -> {e}")
        return None

print_header("Package versions")
hv = safe_ver("huggingface_hub")
pv = safe_ver("pyannote.audio")
tv = safe_ver("torch")
sv = safe_ver("torchaudio")

# warn on unsupported hub versions for pyannote 3.1
try:
    from packaging.version import Version
    if hv and Version(hv) >= Version("1.0.0"):
        print("⚠️  huggingface_hub >= 1.0 detected; pyannote 3.1 generally expects < 1.0.")
        print("   Run: pip install 'huggingface-hub>=0.34.0,<1.0' --force-reinstall")
except Exception:
    pass

# --- 1) Verify token
from huggingface_hub import whoami, model_info, snapshot_download

token = os.getenv("HF_TOKEN") or os.getenv("HUGGING_FACE_HUB_TOKEN")
if not token:
    sys.exit("❌ No HF token found. Set HF_TOKEN='hf_...' in this shell and re-run.")

print_header("Token check")
try:
    info = whoami(token=token)
    print(f"✅ Authenticated as: {info.get('name') or info.get('username')}")
except Exception as e:
    sys.exit(f"❌ Token rejected by whoami(): {e}")

# --- 2) Check access to sd-3.1
MODEL_31 = "pyannote/speaker-diarization-3.1"
MODEL_21 = "pyannote/speaker-diarization@2.1"

print_header("Model access check (3.1)")
try:
    mi = model_info(MODEL_31, token=token)
    print(f"✅ Access OK to {MODEL_31} (sha {mi.sha[:8]})")
    have_31 = True
except Exception as e:
    print(f"❌ Access check failed for {MODEL_31}: {e}")
    print("   Visit https://huggingface.co/pyannote/speaker-diarization-3.1 and click 'Access'.")
    have_31 = False

# --- 3) Try local snapshot of 3.1 (or skip if no access)
local_root = Path.home() / "models"
local_root.mkdir(parents=True, exist_ok=True)
local_31 = local_root / "pyannote-sd3.1"

if have_31:
    print_header(f"Downloading snapshot to {local_31}")
    try:
        path = snapshot_download(
            repo_id=MODEL_31,
            token=token,
            local_dir=str(local_31),
            local_dir_use_symlinks=False,
            recursive=True,
        )
        print("✅ Snapshot ready at:", path)
    except Exception as e:
        print("❌ snapshot_download failed for 3.1:", e)

# --- 4) Try loading pipeline from local path
from pyannote.audio import Pipeline

def try_load_pipeline(name_or_path):
    print_header(f"Loading pipeline: {name_or_path}")
    try:
        pipe = Pipeline.from_pretrained(name_or_path, use_auth_token=token)
        print("✅ Pipeline loaded.")
        return pipe
    except Exception as e:
        print("❌ Pipeline load failed:")
        traceback.print_exc(limit=1)
        return None

pipe = None
if have_31:
    # Prefer local path
    if local_31.exists():
        pipe = try_load_pipeline(str(local_31))
    if pipe is None:
        # Try remote id as a fallback
        pipe = try_load_pipeline(MODEL_31)

# --- 5) Fallback to 2.1 if 3.1 path fails
if pipe is None:
    print_header("Trying fallback: 2.1")
    try:
        mi = model_info(MODEL_21, token=token)
        print(f"✅ Access OK to {MODEL_21} (sha {mi.sha[:8]})")
        local_21 = local_root / "pyannote-sd2.1"
        try:
            p = snapshot_download(
                repo_id=MODEL_21,
                token=token,
                local_dir=str(local_21),
                local_dir_use_symlinks=False,
                recursive=True,
            )
            print("✅ Snapshot ready at:", p)
        except Exception as e:
            print("❌ snapshot_download failed for 2.1:", e)
        pipe = try_load_pipeline(str(local_21)) or try_load_pipeline(MODEL_21)
    except Exception as e:
        print(f"❌ Access check failed for {MODEL_21}: {e}")
        print("   Visit https://huggingface.co/pyannote/speaker-diarization and click 'Access'.")

if pipe is None:
    sys.exit("❌ No diarization pipeline could be loaded. See messages above.")

print_header("SUCCESS")
print("You can now run WhisperX with either:")
print(f"  --diarize_model '{local_31 if have_31 else 'pyannote/speaker-diarization@2.1'}'")
print("or the corresponding repo id.")
