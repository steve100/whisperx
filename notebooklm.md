
## NotebookLM

### The largest file you can upload to NotebookLM is 200MB.
It's also important to know that there is a corresponding word count limit. A single source file cannot exceed 500,000 words, regardless of its file size.
So, for a text file, it will be rejected if it's either over 200MB in size or over 500,000 words long, whichever limit it hits first.

### Other NotebookLM Limits
Here are a few other limitations to keep in mind, which vary between the free and paid (Plus) tiers:

| Feature | Free Tier | NotebookLM Plus |
| :--- | :--- | :--- |
| Max Sources per Notebook | 50 | 300 |
| Max Notebooks | 100 | 500 |
| Daily Chat Queries | 50 | 500 |
| Daily Audio Generations | 3 | 20 |

youtube link: https://www.youtube.com/watch?v=dXX0zvXCgNY

## How to use the cleaner
notebooklm just took the .txt files as is.

```
### chatgpt claims that the whisperx needs conversion.
See whisperx_to_notebooklm.py
python whisperx_to_notebooklm.py yourfile.txt -o notebooklm-ready.md


### Basic: convert to Markdown, keep readable timestamps
python whisperx_to_notebooklm.py input.txt -o cleaned.md

### Merge small chunks (<=2s gap), require same speaker to merge
python whisperx_to_notebooklm.py input.txt -o cleaned.md --merge --require-same-speaker

### Remap diarized speakers and add a title
python whisperx_to_notebooklm.py input.txt -o cleaned.md --merge \
  --map SPEAKER_00=Dean --map SPEAKER_01=Tony --title "AI Advantage Summit – Day 2"

### Output plain text instead of Markdown, no timestamps
python whisperx_to_notebooklm.py input.txt --format txt --no-timestamps -o cleaned.txt

### What it does

## Strips Transcript: prefixes and the --> timing tokens.

## Converts raw seconds or hh:mm:ss.mmm to human [mm:ss] or [hh:mm:ss] ranges.

## Merges consecutive entries (optional) if gap ≤ --gap seconds (default 2.0), and optionally only when the speaker matches.

## Keeps or remaps speaker labels (--map SPEAKER_00=Dean).

## Writes clean .md (NotebookLM-friendly sections) or .txt.
```
```
Good question — NotebookLM works best when your transcript text is clean, structured, and consistent, so it can chunk it into coherent ideas and link them to sources.

Here’s how to convert your WhisperX output into NotebookLM-friendly form.

🧹 Step 1 – Remove technical tokens

Strip out the “Transcript:” prefix and the time ranges.
Instead of:

Transcript: [799.214 --> 822.518]  And in a moment of inspiration ...


Convert to:

[13:19–13:42] And in a moment of inspiration, trying to please this guy...


or simply:

And in a moment of inspiration, trying to please this guy...


Keeping a short human-readable timestamp ([13:19–13:42]) can help NotebookLM link audio-video context, but it’s optional.

🪶 Step 2 – Merge small chunks

WhisperX produces one line per speaker turn or pause; NotebookLM prefers complete thoughts or paragraphs.
Join consecutive lines by the same speaker (if diarized) or those that flow together.

Example:

[13:19–13:42] And in a moment of inspiration, trying to please this guy...
[13:42–14:10] Sure enough, he got it there in 25 minutes.


→

**Speaker 1:** In a moment of inspiration, trying to please this guy, Tom Mahan says, “Listen…”
Sure enough, he got it there in 25 minutes.

🗂 Step 3 – Optional speaker tags

If your WhisperX run included diarization (e.g., SPEAKER_00, SPEAKER_01), keep or rename them to readable labels:

SPEAKER_00 → Speaker 1 (Dean)
SPEAKER_01 → Speaker 2 (Tony)


NotebookLM will then recognize who said what.

✅ Step 4 – Save as plain-text or Markdown

Save as .txt or .md — both upload cleanly to NotebookLM.

Example final format:

### Segment 13:19–13:42  
**Speaker 1 (Dean):** In a moment of inspiration, trying to please this guy, Tom Mahan says, “Listen, I apologize profusely….”  

### Segment 13:42–14:10  
**Speaker 1:** Sure enough, he got it there in 25 minutes.

⚡ Tip

If you plan to analyze or summarize in NotebookLM:

Keep consistent timestamps (MM:SS or HH:MM:SS).

Separate segments by blank lines.

Avoid metadata like Transcript: or --> arrows.

Would you like me to give you a ready-to-run Python script that automatically cleans a WhisperX transcript into this NotebookLM-ready format?

```