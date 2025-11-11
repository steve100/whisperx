# save as run_whisperx.py
import os, torch
import whisperx

AUDIO = "audio.wav"
LANG = "en"
DEVICE = "cpu"
HF_TOKEN = os.environ["HF_TOKEN"]

# 1) Transcribe
model = whisperx.load_model("large-v3", DEVICE, compute_type="int8")
result = model.transcribe(AUDIO, language=LANG)

# 2) Align (optional but recommended)
align_model, metadata = whisperx.load_align_model(language_code=LANG, device=DEVICE)
result = whisperx.align(result["segments"], align_model, metadata, AUDIO, device=DEVICE)

# 3) Diarize (this uses pyannote; works since Python can load your token)
diarize_model = whisperx.DiarizationPipeline(
    model_name="pyannote/speaker-diarization-3.1",
    use_auth_token=HF_TOKEN,
    device=DEVICE,
)
diarize_segments = diarize_model(AUDIO, min_speakers=1, max_speakers=1)

# 4) Assign speaker labels to segments
segments_w_spk = whisperx.assign_word_speakers(diarize_segments, result["segments"])

# 5) Write a simple TXT with timestamps + Speaker 1
out_txt = "out/audio.txt"
os.makedirs("out", exist_ok=True)
with open(out_txt, "w", encoding="utf-8") as f:
    for s in segments_w_spk:
        start = s["start"]; end = s["end"]
        spk = s.get("speaker", "Speaker 1")
        text = s["text"].strip()
        f.write(f"[{start:0>2.0f}:{(start%60):05.2f}–{end:0>2.0f}:{(end%60):05.2f}] {spk}: {text}\n")
print("Wrote", out_txt)
