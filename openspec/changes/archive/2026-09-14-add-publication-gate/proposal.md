# A gate for prose that leaves my hands

**Bean**: [mipnix-jdmy](../../../.beans/mipnix-jdmy--publication-gate-for-generated-prose.md)

## Why

`claude-prose-rules` holds the line on typography and reports filler words, but
only for the subset a script can decide and only when Claude writes through the
Write or Edit tool. Everything that needs a reader is still unguarded: passive
voice, forced triads, the "not X but Y" formula, inflated significance, staged
run-ups, openers and sign-offs. That is the half that makes text read as
machine-written, and it is the half that matters when the text goes to someone
else, in Dutch or in English.

Publication is not a directory. It is the moment prose leaves my hands: written
into a file that is a source of publication, or shown as a draft to copy.

### What the first half taught us

1. **A write-time hook cannot see most of what gets written.** The matcher is
   `Write|Edit`, so prose produced with a shell heredoc (`cat > file <<EOF`)
   passes untouched. In the session that built `claude-prose-rules`, nearly every
   prose file was written exactly that way. A gate on tool calls guards the tool,
   not the text.
2. **The mechanical half is cheap and already built.** `prose-lint` runs the
   typography rules with a code carve-out that keeps a NixOS repository usable.
3. **The judgement half cannot be a script.** Measured on this repository, the
   four em dashes in one document each needed a different repair: a colon, a
   hyphen because it was a numeric range, a sentence break, another colon. An
   automatic rewrite would be wrong more often than right.

Together these say the gate belongs at the moment, not at the write, and that it
has a hard half and a read half.

## What Changes

- **A command that gates prose on request**, in the shape `scripts/ship-change.sh`
  already has for code: you invoke it, it refuses or it passes. It takes the
  files to check, defaulting to the prose changed against `HEAD`, so it sees text
  no matter what wrote it.
- **The hard half runs first.** `prose-lint` over each file. A typography hit
  fails the gate outright. Nothing subjective can fail it.
- **The read half runs second**, against the imported guides, and reports what it
  finds without failing anything. A reader decides.
- **Two guides as flake inputs and skills.** `blader/humanizer` (MIT) is the base
  for both languages, being the only one of the four surveyed that is written to
  be language-neutral. `lboshuizen/dutch-style-guide` (CC-BY-4.0) supplements
  Dutch.
- **A local amendments file**, because both guides carry rules this repository
  rejects. Importing a guide without stating where it does not apply would make
  the output worse, not better.
- **A working agreement**: a draft meant for copying is written to a file rather
  than pasted into a reply, so it passes the same gate. The Stop hook can read a
  reply but cannot fail one without risking an answer/reject/answer loop, so this
  is a habit rather than a mechanism, and the gate is where it becomes visible.

### Scope reduced from the bean

The bean also named `AminBlg/SimpleEnglish` for English technical documents. It
is not imported here. Its skill file carries a REPLY section that forbids
headers, lists, bold, tables and more than five sentences per answer, which
collides with the existing markdown table rule in `~/.claude/CLAUDE.md`, and its
DOCUMENT section overlaps humanizer enough that the collision is not worth
managing. Revisit if English technical documentation turns out to need ASD-STE100
specifically.

## Capabilities

### New Capabilities
- `prose-publication-gate`: the check that prose passes before it leaves my
  hands, covering the rules a reader must judge rather than the ones a script can
  decide, in Dutch and in English.

### Modified Capabilities

## Impact

- `flake.nix`: two inputs with `flake = false`, both personally consumed and
  externally released, which is what the `flake-structure` rule calls for.
- `modules/programs/dev/vibecoding/claude.nix`: two skills, one rules file for
  the amendments, one command.
- `packages/prose-lint/`: reused unchanged. This change depends on the
  command-line mode from `add-prose-lint-cli`.
- No change to `claude-prose-rules`. The hard half keeps behaving exactly as it
  does now, including the hook.
