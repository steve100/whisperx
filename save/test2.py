from pyannote.audio import Pipeline
import os

pipe = Pipeline.from_pretrained(
    "pyannote/speaker-diarization-3.1",
    use_auth_token=os.environ["HF_TOKEN"]
)

# Run on a short audio clip (16 kHz mono wav is ideal)
result = pipe("audio.wav", num_speakers=1)

print(result)  # shows time-stamped speaker turns
for turn, _, speaker in result.itertracks(yield_label=True):
    print(f"[{turn.start:.2f}–{turn.end:.2f}] {speaker}")
