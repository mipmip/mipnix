## Context

See `proposal.md` for motivation and the four measured findings. What matters
for the approach:

- `modules/programs/dev/vibecoding/claude.nix` currently configures
  `programs.claude-code` with `enable`, `package`, `commands`, `context` (one
  long string holding the commit rule, a markdown table rule and the RTK notes)
  and `settings`.
- The locked home-manager (`e28654b7`) exposes more than that module uses:
  `rules`, `hooks`, `hooksDir`, `skills`, `agents`, `outputStyles`, `plugins`,
  `marketplaces`, `mcpServers`, `lspServers`.
- `settings` is free-form JSON written to `~/.claude/settings.json`, and the
  option's own example documents a `hooks.PostToolUse` entry with a
  `matcher = "Edit|MultiEdit|Write"`, so hook registration belongs there.

## Goals / Non-Goals

**Goals:**
- A rule can be added or changed without touching a wall of text.
- The typography rules hold whether or not the model is paying attention.
- The check runs identically in every repository on this machine.

**Non-Goals:**
- Chat replies. Finding 1 in the proposal establishes that the Stop hook cannot
  fail a reply without risking a loop, and the reply is on screen by then.
  Nothing here pretends otherwise.
- The judgement rules (passive voice, triads, "not X but Y", inflated
  significance). Those need a reading pass, not a script, and are
  [mipnix-jdmy](../../../.beans/mipnix-jdmy--publication-gate-for-generated-prose.md).
- Importing humanizer, SimpleEnglish or dutch-style-guide wholesale. Each brings
  rules that conflict with how this repository is written; mining them is the
  job of the publication gate.
- Replacing the existing `context` string. It keeps the commit and RTK rules;
  only writing rules move to `rules`.

## Decisions

### Rule files under `rules`, not another paragraph in `context`

`programs.claude-code.rules` writes one markdown file per attribute into
`~/.claude/rules/`, and the option documents that every markdown file there is
loaded as memory automatically. That gives the structure the request asked for.
The alternative, appending to the single `context` string, was rejected: it
already mixes a git policy, a markdown table rule and a CLI cheat sheet, and a
fourth concern makes it worse.

Two files to start: one for the typography rules, one for the filler list. They
are separate because they have different severities and different lifetimes; the
filler list will grow as more tics are noticed, the typography rules will not.

### A Nix-built executable, not `programs.claude-code.hooks`

`hooks` writes its content through `mkTextEntries`, which emits
`{ text = content; }` with no executable bit, so a script placed there cannot be
invoked directly. Working around that by naming an interpreter in the command
string reintroduces exactly the PATH dependency that makes SimpleEnglish's hooks
fragile: its manifest calls `node` and `python3` by bare name, so its hooks are
silently dead in any shell that lacks them.

Instead the linter is built as a derivation and referenced by store path from
`settings.hooks.PostToolUse`. The interpreter is resolved at build time, the
file is executable, and the hook cannot break because of what is or is not on
PATH. `hooksDir` was also considered and rejected for the same reason: it
symlinks a directory of files, which does not solve the interpreter.

### Two severities, because the rules are not the same kind of rule

| rule | decidable by a script? | severity |
|-------------------------------|------------------------|-----------------|
| em dash, en dash, ` -- `      | yes, unambiguous       | exit 2, blocks  |
| curly quotation marks         | yes, unambiguous       | exit 2, blocks  |
| filler words                  | no, context decides    | reported only   |

Making the filler list blocking would be wrong on its own terms. The request was
that the word is allowed when it adds meaning, and only unwanted as a tic. A
script cannot tell "dat is eigenlijk niet waar" from "dat is eigenlijk best
goed". Reporting the hit with its sentence puts the judgement where it belongs
while still making the tic visible.

### The carve-out is copied from humanizer rule 8, verbatim in intent

Dashes and hyphens inside fenced code blocks, inline code, commands, paths and
URLs are left alone. This is not a refinement to add later: without it, a NixOS
repository produces a hit on nearly every line, the check gets switched off, and
the whole change is wasted. humanizer is MIT, and only the rule is borrowed.

### Prose file types only, in this version

`.md`, `.txt`, `.html`, `.rst`, `.adoc`. Source files are skipped entirely. The
rules do apply to a comment in a `.nix` file in principle, but a whole-file
carve-out for source syntax is a much larger problem than the one being solved,
and getting it wrong trains the user to ignore the check. Revisit once the
prose case has proven itself.

## Risks / Trade-offs

- **The check fires on drafts that were never meant to be careful.** Any
  scratch markdown gets the same treatment. Mitigation: the typography rules are
  cheap to satisfy and the filler report does not block. If it grates, an
  exclusion list keyed on path is the next step, mirroring
  `SIMPLE_ENGLISH_LINT_EXCLUDE`.
- **A blocking hook that misfires stops work.** Mitigation: only rules with no
  legitimate exception block, and the carve-out removes the one large source of
  false positives. Anything uncertain reports instead.
- **The filler list starts as a guess.** The first version is the candidate set
  from the bean rather than an observed list. It is a data file precisely so
  that correcting it is a one-line edit, not a redesign.
- **Trade-off: prose files only.** An em dash in a `.nix` comment still gets
  through. Accepted for now; see the decision above.

## Migration Plan

Additive. The existing `context` string keeps its current content, so nothing
that works today changes behaviour. Rollback is reverting the commit and
rebuilding: the rule files and the settings entry disappear with it, and no
state lives outside the store.
