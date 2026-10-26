## Context

See proposal.md for motivation. What decided the approach, checked against the
opencode 2 source tree rather than against its docs, which are stale on two of
these points:

- `packages/core/src/config/plugin/command.ts:159` scans
  `{command,commands}/**/*.md`, and `:184` derives the name from the path with
  `.replace(/^(command|commands)\//, "").replace(/\.md$/, "")`.
- `packages/app/src/composer/client-slash-command.ts` takes the command name as
  everything between `/` and the first whitespace. So a file named
  `mip:ship.md` answers to `/mip:ship`, the same string Claude Code uses.
- `packages/schema/src/config/command.ts` accepts `template`, `description`,
  `agent`, `model`, `subagent` and `subtask`, decoded with effect-Schema's
  default `onExcessProperty: "ignore"`. `argument-hint` and `allowed-tools` are
  dropped silently.
- `packages/core/src/config/plugin/compatibility.ts:40` joins each `.claude`
  root with `skills` and scans `{*.md,**/SKILL.md}`. That is the only use v2
  makes of `~/.claude`.
- `packages/core/src/config/plugin/instruction.ts:38` walks `AGENTS.md` and
  nothing else. No `CLAUDE.md`, and no `OPENCODE_DISABLE_CLAUDE_CODE*` variable
  exists anywhere outside the bundled documentation.
- `config.instructions` is declared in `packages/schema/src/config.ts:94` and
  normalized in `normalize.ts:227`, and no plugin reads it.
- `packages/core/src/reference/instructions.ts` renders references as
  "additional directories that can be accessed when relevant", a catalogue
  rather than inlined text.
- `packages/core/src/session/context.ts:150` is the chain that reaches the
  prompt: codemode, mcp, references, skills, discovery, builtins, entries.
  `discovery` is the `AGENTS.md` walk.

So of the four things to share, opencode 2 reads one of them from `~/.claude`
unaided (skills), and for the rest the only always-inlined global channel is
`~/.config/opencode/AGENTS.md`.

## Goals / Non-Goals

**Goals:**

- One place to write a command, a rule or a line of context, serving both
  agents.
- No per-agent copy of the text, so the two cannot drift.
- Claude Code's arrangement unchanged: separate rule files it loads as memory.

**Non-Goals:**

- A `prose-lint` equivalent for opencode. Separate change.
- Sharing `settings.json`: hooks, the status line and `includeCoAuthoredBy` have
  no opencode counterpart.
- Sharing agents or subagent definitions. There are none declared here.
- Making the rules separate documents in opencode. v2 offers no mechanism.

## Decisions

### Nix is the source of truth, not the filesystem

Two shapes were possible. Point opencode at `~/.claude` and let its
compatibility paths do the work, or keep the text in Nix and render it twice.

The filesystem shape only covers skills. The `CLAUDE.md` fallback is gone in v2,
`~/.claude/commands` was never read, and `~/.claude/rules` was never read. So
pointing at the filesystem would share one of four things and leave the other
three to be duplicated by hand.

The text is already in Nix. Rendering it twice costs an import and a
concatenation, and it is the only shape that covers commands, context and rules
at once.

### Commands are shared without editing the text

`mip:ship.md` is a valid opencode command file exactly as Claude Code receives
it: the name matches, the argument placeholders match, the shell and file
syntaxes match, and the one frontmatter key opencode does not know is ignored
rather than rejected.

So the attribute set is shared, not translated. This is the part of the change
with the least to go wrong, and it is worth not inventing a translation layer
for it.

The home-manager module writes `xdg.configFile."opencode/commands/${name}.md"`,
so the colon in the attribute name lands in the filename, which is what the
scan then strips back off.

### Rules reach opencode concatenated, and that is a real loss

Claude Code loads every markdown file in `~/.claude/rules/` as memory, which is
why `claude.nix` keeps the three concerns in three files: a rule can be added or
removed on its own.

opencode 2 has no equivalent. `instructions` looks like one and is inert.
`references` is a catalogue, so a rule placed there would be a path the model is
told it may read, not a rule it has been given. The only channel that inlines
text unconditionally is `AGENTS.md`.

So the rules are concatenated into `AGENTS.md` under their own headings. The
granularity survives in the Nix source and in Claude Code; it does not survive
into opencode's file. Recorded here rather than discovered later.

### Skills stay where they are

`programs.opencode.skills` is left unset. opencode's compatibility plugin reads
`~/.claude/skills/<name>/SKILL.md` directly, and both installed skills carry the
`name` and `description` frontmatter it wants, with the directory name as a
fallback. Declaring them again would put a second copy under
`~/.config/opencode/skills/` for no gain.

This is the one place where the filesystem is the shared source, and it works
because opencode chose to support it.

### The hook is not shared, and the rules say so

`prose-lint` runs as a Claude Code `PostToolUse` hook on `Write|Edit`. opencode
has plugins, not hooks, and `tool.execute.after` is the matching point. Writing
that plugin is a separate change.

Until it exists, the typography rules are enforced in Claude Code and are advice
in opencode. The `claude-prose-rules` capability says enforcement is what keeps
the rules from depending on the model remembering them, so the gap has to be
stated in the spec rather than left implied.

## Risks / Trade-offs

- A command could gain Claude-specific frontmatter later and be silently ignored
  by opencode. Ignored rather than broken, but silent. The shared file is the
  place to note that frontmatter has to work for both.
- `AGENTS.md` grows: the context plus three rule texts in one file. It is read
  every session, so it costs tokens in every opencode session.
- Renaming three files touches `mip-init-command`, which names one of them. The
  rename is still right: `_cc-` means claude-code, and the file stops being that.
- opencode may add a rules directory or make `instructions` work, at which point
  the concatenation should be revisited.

## Open Questions

- Should `includeCoAuthoredBy = false` have an opencode counterpart? Claude Code
  adds a trailer and opencode may not, so there may be nothing to turn off.
  Worth checking before anyone assumes the commit convention is covered.
