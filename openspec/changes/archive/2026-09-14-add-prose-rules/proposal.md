# Always-on prose rules, enforced on file writes

**Bean**: [mipnix-pdlz](../../../.beans/mipnix-pdlz--always-on-prose-rules-for-claude-code-enforced-on.md)

## Why

Claude Code writes prose into files that end up in front of other people: README
files, documentation, drafts, website copy. Two habits keep leaking through, in
Dutch and in English alike: the em dash used as an all-purpose connector, and
filler words that add nothing ("letterlijk" as a verbal tic rather than to mean
"word for word").

Guidance alone does not hold. The global `CLAUDE.md` is in context for every
session, and its commit-attribution rule is obeyed reliably, because that rule
governs a deliberate action. Punctuation is not a deliberate action. It needs a
check that runs after the fact and hands the violations back.

These rules are not publication-specific. There is no context where an em dash
is wanted: not in a blog post, not in a spec, not in a commit message. So they
need no publication detector. Scoping is left to the judgement rules, which are
a separate change ([mipnix-jdmy](../../../.beans/mipnix-jdmy--publication-gate-for-generated-prose.md)).

### Findings that shape this

Measured, not assumed:

1. **PostToolUse can enforce; Stop cannot.** In SimpleEnglish's `lint_hook.py`,
   PostToolUse writes violations to stderr and exits 2, which returns them to
   the model as something it must fix. The Stop handler does receive
   `last_assistant_message`, so inspecting a chat reply is possible, but it
   returns 0 on purpose: blocking there risks an answer/reject/answer loop, and
   the reply is already on screen. Files are therefore the only surface where a
   hard gate is honest.
2. **`programs.claude-code.hooks` writes non-executable files.** Its
   `mkTextEntries` emits `{ text = content; }` with no executable bit, so a
   script placed there cannot be invoked directly.
3. **Nothing upstream covers filler words.** Zero hits for `letterlijk`,
   `literally`, `filler` or `stopwoord` across humanizer, SimpleEnglish and
   dutch-style-guide. This list has to be ours.
4. **humanizer has the carve-out that makes this survivable.** Its rule 8 leaves
   dashes and hyphens inside code blocks, inline code, commands, paths and URLs
   alone. Without that, a NixOS repo is one long false positive.

## What Changes

- **Rule files, one per concern**, through `programs.claude-code.rules`. Every
  markdown file in `~/.claude/rules/` is loaded as memory automatically, which
  is the structured home the current single `context` string does not give.
- **A prose linter built by Nix**, referenced from `settings.hooks.PostToolUse`
  with matcher `Write|Edit`. Built as a store-path executable with its
  interpreter baked in, so it never depends on `node` or `python3` being on
  PATH, and so finding 2 above does not apply.
- **Two severities, because the rules differ in kind.** Dashes and curly quotes
  are never wanted, so they exit 2 and must be fixed. Filler words are
  context-dependent ("dat is eigenlijk niet waar" carries meaning, "dat is
  eigenlijk best goed" does not), so they are reported with their sentence and
  do not block. A flagging list, not a ban list.
- **Scoped to prose file types** in this first version: `.md`, `.txt`, `.html`,
  `.rst`, `.adoc`. Source files are skipped.

## Capabilities

### New Capabilities
- `claude-prose-rules`: the writing rules Claude Code follows in every project,
  and the mechanical check that holds it to the ones that admit no exception.

### Modified Capabilities

## Impact

- `modules/programs/dev/vibecoding/claude.nix`: `rules`, a `settings.hooks`
  entry, and the linter derivation. Reaches both HM roles that import
  `vibecoding-claude-code-config` (`home-pim-cli-full`, `home-pim-cli-server-dev`).
- `~/.claude/rules/` and `~/.claude/settings.json` gain entries. Global across
  every repository, which is the point.
- No effect on chat replies. That surface cannot be gated and is left alone.
