---
# mipnix-pdlz
title: always-on prose rules for Claude Code, enforced on file writes
status: in-progress
type: feature
priority: normal
tags:
    - claude-code
    - writing
created_at: 2026-09-14T16:16:12Z
updated_at: 2026-09-14T16:45:13Z
---

Give Claude Code a structured, always-on set of writing rules in home-manager,
plus a mechanical check that cannot be talked out of.

Two of my rules hold everywhere, in a blog post, a spec, a commit message and a
chat reply alike: no em dash, and no filler words that add nothing ("letterlijk"
used as a verbal tic rather than to mean "word for word"). Because there is no
context where I want them, they need no publication detector. Apply them
unconditionally and keep the scoping work for the judgement rules
([[mipnix-jdmy]]).

Structure in home-manager: `programs.claude-code.rules` writes one markdown file
per rule set into `~/.claude/rules/`, and every file there is loaded as memory
automatically. That beats appending another block to the single `context`
string. One file per concern: em-dash, stopwoorden, and later the imported
guides.

Enforcement: a PostToolUse hook. Measured in SimpleEnglish's `lint_hook.py`:
PostToolUse writes the violations to stderr and exits 2, which hands them back
to the model as something it must fix before continuing. That is real
enforcement, not advice. Note that `programs.claude-code.hooks` only drops the
script into `~/.claude/hooks/`; registering it (event, matcher) is a separate
entry under `settings.hooks.PostToolUse`.

Scope the checker to what a script can decide without a model: em dash, en dash,
spaced dashes and double hyphens, curly quotation marks, the filler list, and
humanizer's rule 12 vocabulary list. Take the carve-out from humanizer rule 8
verbatim: leave dashes and hyphens inside code blocks, inline code, commands,
paths and URLs alone. Without it a NixOS repo is one long false positive.

Blocked on one input that only I can give: the filler list itself. It has to be
a flagging list, not a ban list. "Eigenlijk" carries meaning in "dat is eigenlijk
niet waar" and none in "dat is eigenlijk best goed". Candidates: eigenlijk,
gewoon, natuurlijk, simpelweg, in feite, daadwerkelijk, als het ware, uiteraard,
and the English literally, basically, actually, simply, just, really.

Reference material, all MIT unless noted: blader/humanizer (25 rules from
Wikipedia's "Signs of AI writing", the sharpest em-dash rule of the four),
AminBlg/SimpleEnglish (working linter to copy from), lboshuizen/dutch-style-guide
(CC-BY-4.0), ayghri/i-have-adhd (SessionStart hook gated by a flag file, a clean
pattern for switching a ruleset on declaratively). None of the four knows the
concept of a filler word: zero hits on letterlijk, literally, filler, stopwoord.
