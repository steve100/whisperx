#!/usr/bin/env python3
"""
Convert WhisperX-style transcript lines to a NotebookLM-friendly Markdown structure.

Input line examples accepted:
- "Transcript: [799.214 --> 822.518]  Text ..."
- "[00:13:19.214 --> 00:13:42.518] SPEAKER_00: Text ..."
- "[13:19.214 --> 13:42.518] Text ..."
- "[1.23 --> 5.67] Text ..."

Features:
- Removes "Transcript:" or similar prefixes.
- Converts second-based timestamps to mm:ss or hh:mm:ss.
- Optional merging of consecutive entries (same speaker OR small time gap).
- Optional speaker remap (e.g., --map SPEAKER_00=Dean --map SPEAKER_01=Tony).
- Outputs clean Markdown (.md) or plain text (.txt) with simple sections.

Usage:
  python whisperx_to_notebooklm.py input.txt -o output.md --merge --gap 2 --format md --title "My Talk" \
      --map SPEAKER_00=Dean --map SPEAKER_01=Tony
"""

import re
import sys
from pathlib import Path
import argparse
from typing import Optional, List, Tuple, Dict

LINE_RE = re.compile(
    r"""^\s*
        (?:(?P<prefix>\w+):\s*)?                              # Optional "Transcript:" or similar
        \[\s*(?P<start>[\d:\.]+)\s*-->\s*(?P<end>[\d:\.]+)\s*\]\s*  # [start --> end]
        (?:(?P<speaker>(?:SPEAKER[_\s]?\d+|Speaker\s*\d+|[A-Za-z][\w .'-]{0,40})):\s*)?  # optional speaker tag
        (?P<text>.*)\s*$
    """,
    re.VERBOSE,
)

def parse_time_to_seconds(s: str) -> float:
    """Accepts '799.214' or '13:19.214' or '00:13:19.214' and returns seconds (float)."""
    if ":" not in s:
        try:
            return float(s)
        except ValueError:
            return 0.0
    # Handle hh:mm:ss(.ms) or mm:ss(.ms) or h:mm:ss
    parts = s.split(":")
    parts = [p for p in parts if p != ""]  # be defensive
    try:
        if len(parts) == 3:
            h = int(parts[0])
            m = int(parts[1])
            sec = float(parts[2])
            return h * 3600 + m * 60 + sec
        elif len(parts) == 2:
            m = int(parts[0])
            sec = float(parts[1])
            return m * 60 + sec
        else:
            # Unexpected, fallback
            return float(parts[-1])
    except Exception:
        return 0.0

def seconds_to_hhmmss(secs: float) -> str:
    secs = max(0.0, float(secs))
    h = int(secs // 3600)
    m = int((secs % 3600) // 60)
    s = secs - (h * 3600 + m * 60)
    if h > 0:
        return f"{h:02d}:{m:02d}:{s:05.2f}".replace(".", ":") if False else f"{h:02d}:{m:02d}:{int(s):02d}"
    else:
        return f"{m:02d}:{int(s):02d}"

def human_range(start_s: float, end_s: float) -> str:
    start = seconds_to_hhmmss(start_s)
    end = seconds_to_hhmmss(end_s)
    return f"{start}–{end}"

class Segment:
    def __init__(self, start: float, end: float, text: str, speaker: Optional[str] = None):
        self.start = start
        self.end = end
        self.text = text.strip()
        self.speaker = speaker.strip() if speaker else None

    def can_merge_with(self, other: "Segment", gap: float, require_same_speaker: bool) -> bool:
        if require_same_speaker:
            if (self.speaker or other.speaker) and (self.speaker != other.speaker):
                return False
        # allow merge if time gap small or overlaps
        return (other.start - self.end) <= gap

    def merge(self, other: "Segment"):
        self.end = max(self.end, other.end)
        if self.text and other.text:
            if self.text.endswith("-"):  # naive hyphenated joining
                self.text = self.text[:-1] + other.text.lstrip()
            else:
                # add space if needed
                sep = "" if (self.text.endswith((" ", "\n")) or other.text.startswith((" ", "\n"))) else " "
                self.text += sep + other.text.lstrip()
        elif other.text:
            self.text = other.text

def parse_lines(lines: List[str]) -> List[Segment]:
    segs: List[Segment] = []
    for ln in lines:
        m = LINE_RE.match(ln)
        if not m:
            # if it's a bare text line, append as a no-time segment with None times and will be handled later
            # But to keep ordering, ignore non-matching lines unless they have meaningful text.
            stripped = ln.strip()
            if stripped:
                # Append with artificial times increasing; but simpler: keep as text-only with 0 times.
                segs.append(Segment(0.0, 0.0, stripped, None))
            continue
        start_raw = m.group("start")
        end_raw = m.group("end")
        speaker = m.group("speaker")
        text = m.group("text")

        start_s = parse_time_to_seconds(start_raw)
        end_s = parse_time_to_seconds(end_raw)
        segs.append(Segment(start_s, end_s, text, speaker))
    return segs

def apply_speaker_map(segs: List[Segment], spk_map: Dict[str, str]) -> None:
    if not spk_map:
        return
    for s in segs:
        if s.speaker and s.speaker in spk_map:
            s.speaker = spk_map[s.speaker]

def merge_segments(segs: List[Segment], gap: float, require_same_speaker: bool) -> List[Segment]:
    if not segs:
        return segs
    out: List[Segment] = [segs[0]]
    for cur in segs[1:]:
        last = out[-1]
        if last.can_merge_with(cur, gap=gap, require_same_speaker=require_same_speaker):
            last.merge(cur)
        else:
            out.append(cur)
    return out

def render_markdown(segs: List[Segment], title: Optional[str] = None, include_timestamps: bool = True) -> str:
    lines: List[str] = []
    if title:
        lines.append(f"# {title}")
        lines.append("")

    for s in segs:
        ts = human_range(s.start, s.end) if include_timestamps else None
        if ts:
            lines.append(f"### Segment {ts}")
        else:
            lines.append(f"### Segment")

        if s.speaker:
            lines.append(f"**{s.speaker}:** {s.text}")
        else:
            lines.append(s.text)

        lines.append("")  # blank line between segments
    return "\n".join(lines).rstrip() + "\n"

def render_text(segs: List[Segment], include_timestamps: bool = True) -> str:
    lines: List[str] = []
    for s in segs:
        ts = f"[{human_range(s.start, s.end)}] " if include_timestamps else ""
        spk = f"{s.speaker}: " if s.speaker else ""
        lines.append(f"{ts}{spk}{s.text}")
    return "\n".join(lines).rstrip() + "\n"

def main(argv: Optional[List[str]] = None) -> int:
    p = argparse.ArgumentParser(description="Convert WhisperX transcript to NotebookLM-friendly format.")
    p.add_argument("input", type=str, help="Path to input transcript (.txt)")
    p.add_argument("-o", "--output", type=str, default=None, help="Output file path. Defaults to input name with .md")
    p.add_argument("--format", choices=["md", "txt"], default="md", help="Output format")
    p.add_argument("--no-timestamps", action="store_true", help="Do not include human-readable timestamps")
    p.add_argument("--merge", action="store_true", help="Merge consecutive entries")
    p.add_argument("--gap", type=float, default=2.0, help="Max seconds gap to allow merges (default: 2.0)")
    p.add_argument("--require-same-speaker", action="store_true", help="Only merge when speakers are identical")
    p.add_argument("--title", type=str, default=None, help="Optional document title (for Markdown)")
    p.add_argument("--map", action="append", default=[], help="Speaker remap entries like SPEAKER_00=Dean")
    args = p.parse_args(argv)

    in_path = Path(args.input)
    if not in_path.exists():
        print(f"Error: input not found: {in_path}", file=sys.stderr)
        return 2

    lines = in_path.read_text(encoding="utf-8", errors="ignore").splitlines()
    segs = parse_lines(lines)

    # Build speaker map
    spk_map = {}
    for m in args.map:
        if "=" in m:
            k, v = m.split("=", 1)
            spk_map[k.strip()] = v.strip()
    apply_speaker_map(segs, spk_map)

    if args.merge:
        segs = merge_segments(segs, gap=args.gap, require_same_speaker=args.require_same_speaker)

    include_ts = not args.no_timestamps

    if args.format == "md":
        out_text = render_markdown(segs, title=args.title, include_timestamps=include_ts)
        out_ext = ".md"
    else:
        out_text = render_text(segs, include_timestamps=include_ts)
        out_ext = ".txt"

    out_path = Path(args.output) if args.output else in_path.with_suffix(out_ext)
    out_path.write_text(out_text, encoding="utf-8")
    print(f"Wrote {out_path}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
