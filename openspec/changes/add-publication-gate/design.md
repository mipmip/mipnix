## Context

See `proposal.md` for motivation and the three findings from building
`claude-prose-rules`. The state this builds on:

- `packages/prose-lint/` holds the mechanical checker. Its command-line mode
  comes from `add-prose-lint-cli`, which this change depends on.
- `programs.claude-code` already carries `rules`, `settings.hooks` and a
  `commands` attribute (`_cc-commands.nix`). It also exposes `skills`, which
  accepts a store path or a subdirectory of one.
- `blader/humanizer` keeps its `SKILL.md` at the repository root with complete
  frontmatter, so a single file is enough. `lboshuizen/dutch-style-guide` keeps
  `SKILL.md` and its 25 KB reference together under
  `skills/writing-clearly-and-concisely-dutch/`, and the SKILL.md refers to the
  reference by name, so that one needs the whole directory.

## Goals / Non-Goals

**Goals:**
- Cover the half of the writing rules a script cannot decide.
- Work on text however it was produced.
- Keep the hard half and the soft half visibly separate, so a subjective reading
  can never be what fails a gate.

**Non-Goals:**
- Gating chat replies. The Stop hook can read `last_assistant_message`, but
  returning an error there risks an answer/reject/answer loop and the reply is
  already on screen. The working agreement about drafts is the answer instead.
- Rewriting text automatically. See the decision below.
- Importing `SimpleEnglish`. See the proposal's scope note.
- Touching `claude-prose-rules`. The hook and the typography rules stay exactly
  as they are.

## Decisions

### The gate is a moment, not a trigger

The alternative was a hook on writes, which is what the first half does. It was
rejected on evidence rather than taste: the matcher is `Write|Edit`, and prose
written with `cat > file <<EOF` never reaches it. That is not a corner case. In
the session that built the first half, almost every document was written that
way, which means a write-time gate would have guarded almost nothing.

Running on request also matches how this repository already works. Code has
`scripts/ship-change.sh`: you invoke it, it refuses or it passes. Prose gets the
same shape, and defaults to the prose that differs from `HEAD` so that invoking
it needs no arguments.

The cost is that it must be remembered. That is accepted, because a gate that
covers the text is better than one that covers a tool call.

### Hard half and soft half never mix

| half | decided by | can it fail the gate? |
|-------------|-----------------------------|-----------------------|
| typography  | `prose-lint`, mechanically  | yes                   |
| judgement   | a reading against the guides| no, reports only      |

Keeping these apart is what makes the gate trustworthy. If a reading could fail
it, the gate would be unpredictable, and an unpredictable gate gets bypassed. A
typography hit is decidable, repeatable and never a matter of opinion, so that is
the only thing allowed to say no.

### No automatic rewriting

Measured on `docs/spike-tmux-reading-mode.md`, four em dashes needed four
different repairs: a colon in a heading, a hyphen because the dash sat in the
numeric range 80 to 90, a full stop to break a sentence, and another colon. A
substitution rule would have produced the wrong one three times out of four. The
same holds for filler: keeping or dropping "eigenlijk" depends on whether the
sentence is correcting a claim.

So the gate reports and the reader decides. Where a repair is agreed, it is made
as an ordinary edit, and the hard half then verifies it on the way out.

### Guides come in as flake inputs with `flake = false`

Both are released independently and maintained elsewhere, which under the
`flake-structure` rule means an external input rather than a copy under
`packages/`. `flake = false` because neither is a flake; the precedent is
`beans-nvim`, consumed the same way.

Licences differ and both are compatible with consuming the text as guidance:
humanizer is MIT, dutch-style-guide is CC-BY-4.0. Attribution stays intact
because the skill files are used unmodified.

### The amendments file is what makes importing safe

Both guides carry rules that are wrong for this material:

- The Dutch guide treats an English technical term as a red flag and asks for
  `prestaties` over `performance`, `opnieuw proberen` over `retry`. Applied to
  text about flakes, locks and closures, that costs accuracy. It also breaks the
  typography rule nineteen times in its own headings, which is a useful reminder
  that a guide is not automatically consistent with itself.
- humanizer's rule 12 is an English vocabulary list, and it says so.

Rather than fork either guide, the amendments live in one local file next to
them, and the review is instructed to read the guide through the amendments. The
guides can then be updated by a flake update without losing the local position.

### Language is read, not configured

The reviewer reads the document and knows what language it is in. A configuration
switch would be a setting to get wrong for no benefit, and a per-file marker
would put process metadata into the text.

## Risks / Trade-offs

- **The gate has to be remembered.** No trigger fires it. Mitigation: it defaults
  to the changed prose, so running it costs one word, and the habit of writing
  drafts to files puts the text where the default finds it. If it turns out to be
  forgotten in practice, a reminder at the end of a session is the next step, not
  an automatic rewrite.
- **The reading half is not reproducible.** Two runs may report different things.
  That is inherent to the half that needs a reader, and it is exactly why this
  half is not allowed to fail the gate.
- **An imported guide can change under a flake update.** A rule this repository
  relies on could be reworded or dropped upstream. Mitigation: the amendments
  file names the rules it depends on, so a surprising review result has somewhere
  to be checked against.
- **Trade-off: the working agreement is a habit, not a mechanism.** A draft
  pasted into a reply still escapes. Accepted, with the reason recorded: making
  it a mechanism risks looping the session.

## Migration Plan

Additive, and ordered after `add-prose-lint-cli` because the gate calls the
command-line mode that change introduces. Nothing existing changes behaviour:
the hook, the rules files and `prose-lint` itself are untouched. Rolling back is
reverting the commit and rebuilding, which removes the skills, the amendments
file and the command, and leaves the first half intact.
