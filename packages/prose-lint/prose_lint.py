"""Prose linter for Claude Code's PostToolUse hook.

Two severities, because the rules are not the same kind of rule. Typography that
no context calls for (em dash, en dash, a spaced double hyphen used as a dash,
curly quotation marks) fails the write: the hits go to stderr and the process
exits 2, which hands them back to the model to fix. Filler words are reported
with the sentence they sit in and never fail anything, because only a reader can
tell "dat is eigenlijk niet waar" (meaning) from "dat is eigenlijk best goed"
(a tic).

Regions that are not prose are masked before any rule runs: fenced code blocks,
inline code, URLs and filesystem paths. Without that carve-out a NixOS repo
produces a hit on nearly every line and the check gets switched off. The mask
replaces characters with spaces so line and column numbers stay true.
"""

import json
import os
import re
import sys
from pathlib import Path

FILLER_WORDS_PATH = "@FILLER_WORDS@"

PROSE_SUFFIXES = {".md", ".txt", ".html", ".rst", ".adoc"}

MAX_HITS_SHOWN = 20

# Blocking rules. Each is (name, compiled pattern, what to do instead).
BLOCKING = [
    ("em dash", re.compile("—"), "use a comma, a colon, parentheses, or two sentences"),
    ("en dash", re.compile("–"), "use a hyphen in a range, otherwise rewrite"),
    ("double hyphen as dash", re.compile(r"(?<= )--(?= )"), "same as the em dash"),
    ("curly quote", re.compile("[‘’“”]"), "use a straight quote"),
]

FENCE = re.compile(r"^\s*(```|~~~)")
INLINE_CODE = re.compile(r"`[^`\n]*`")
URL = re.compile(r"\b[a-z][a-z0-9+.-]*://\S+", re.IGNORECASE)
# A path-like token: contains a slash, no whitespace, and is not bare punctuation.
PATHLIKE = re.compile(r"(?<!\S)[~./][^\s]*/[^\s]*|(?<!\S)/[^\s]+")
HTML_CODE = re.compile(r"<(code|pre)\b.*?</\1>", re.IGNORECASE | re.DOTALL)
SENTENCE_SPLIT = re.compile(r"(?<=[.!?])\s+")


def blank(match):
    """Replacement that keeps length and newlines, so offsets do not move."""
    return "".join("\n" if ch == "\n" else " " for ch in match.group(0))


def mask(text):
    """Blank out every region where a dash or a quote is not prose."""
    lines = text.split("\n")
    out = []
    in_fence = False
    for line in lines:
        if FENCE.match(line):
            in_fence = not in_fence
            out.append(" " * len(line))
            continue
        out.append(" " * len(line) if in_fence else line)
    masked = "\n".join(out)
    for pattern in (HTML_CODE, INLINE_CODE, URL, PATHLIKE):
        masked = pattern.sub(blank, masked)
    return masked


def load_filler_words():
    path = FILLER_WORDS_PATH
    if path.startswith("@"):
        path = str(Path(__file__).resolve().parent / "filler-words.json")
    try:
        with open(path, encoding="utf-8") as handle:
            data = json.load(handle)
    except Exception:
        return []
    words = []
    for group in data.values():
        words.extend(group)
    # Longest first, so "in feite" wins over a bare word inside it.
    return sorted(set(words), key=len, reverse=True)


def find_blocking(masked):
    hits = []
    for lineno, line in enumerate(masked.split("\n"), start=1):
        for name, pattern, advice in BLOCKING:
            for found in pattern.finditer(line):
                hits.append((lineno, name, advice, line.strip(), found.start()))
    return hits


def sentence_at(text, index):
    start = text.rfind("\n\n", 0, index)
    start = 0 if start < 0 else start + 2
    end = text.find("\n\n", index)
    end = len(text) if end < 0 else end
    block = " ".join(text[start:end].split())
    offset = len(" ".join(text[start:index].split()))
    for sentence in SENTENCE_SPLIT.split(block):
        span = len(sentence) + 1
        if offset <= span:
            return sentence.strip()
        offset -= span
    return block.strip()


def find_filler(text, masked, words):
    hits = []
    for word in words:
        pattern = re.compile(r"(?<!\w)" + re.escape(word) + r"(?!\w)", re.IGNORECASE)
        for found in pattern.finditer(masked):
            lineno = masked.count("\n", 0, found.start()) + 1
            hits.append((lineno, word, sentence_at(text, found.start())))
    hits.sort()
    return hits


def report(path, blocking, filler):
    lines = []
    if blocking:
        lines.append(f"prose-lint: {len(blocking)} typography violation(s) in {path}.")
        for lineno, name, advice, text, _ in blocking[:MAX_HITS_SHOWN]:
            lines.append(f"  line {lineno}, {name}: {text}")
            lines.append(f"    instead: {advice}")
        if len(blocking) > MAX_HITS_SHOWN:
            lines.append(f"  and {len(blocking) - MAX_HITS_SHOWN} more.")
        lines.append("Fix these in the file you just wrote, then continue.")
    if filler:
        lines.append(f"prose-lint: {len(filler)} possible filler word(s) in {path}.")
        lines.append("Not a failure. Keep the word where it carries meaning, drop it where it is a tic.")
        for lineno, word, sentence in filler[:MAX_HITS_SHOWN]:
            lines.append(f"  line {lineno}, \"{word}\": {sentence}")
        if len(filler) > MAX_HITS_SHOWN:
            lines.append(f"  and {len(filler) - MAX_HITS_SHOWN} more.")
    if lines:
        sys.stderr.write("\n".join(lines) + "\n")


def check_text(text, words):
    masked = mask(text)
    return find_blocking(masked), find_filler(text, masked, words)


def run(event):
    tool_input = event.get("tool_input") or {}
    raw = tool_input.get("file_path") or ""
    if not raw:
        return 0
    path = Path(raw)
    if not path.is_absolute():
        path = Path(event.get("cwd") or os.getcwd()) / path
    if path.suffix.lower() not in PROSE_SUFFIXES:
        return 0
    try:
        text = path.read_text(encoding="utf-8")
    except Exception:
        return 0
    blocking, filler = check_text(text, load_filler_words())
    report(path, blocking, filler)
    return 2 if blocking else 0


def main():
    try:
        event = json.load(sys.stdin)
    except Exception:
        return 0
    if not isinstance(event, dict):
        return 0
    try:
        return run(event)
    except Exception:
        # An advisory hook must never break a session.
        return 0


if __name__ == "__main__":
    sys.exit(main())
