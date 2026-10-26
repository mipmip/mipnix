## Why

The slash commands, the global context and the writing rules are written once,
in Nix, and reach one agent. `_cc-commands.nix` holds eight `mip:` commands,
`_cc-CLAUDEmd.nix` holds the global context, and `claude.nix` holds three
writing rules, and all of it is consumed by `programs.claude-code` alone.
`programs.opencode` sets `agents = {}` and `commands = {}`.

So opencode has none of it. Typing `/mip:ship` there does nothing, and the
machine's writing rules, which a hook enforces on every Claude Code write, do
not reach it at all.

Nothing about the content is Claude-specific. What differs is only where each
agent reads it from, and in two of the four cases opencode already reads the
Claude Code location itself.

## What Changes

- Rename `_cc-commands.nix` to `_agent-commands.nix` and feed the same attribute
  set to both `programs.claude-code.commands` and `programs.opencode.commands`.
  The files need no editing: opencode derives a command's name from its path
  with `.replace(/^(command|commands)\//, "").replace(/\.md$/, "")`, so
  `commands/mip:ship.md` becomes `/mip:ship` in both agents, and its frontmatter
  decodes with excess properties ignored, so `argument-hint` is dropped rather
  than rejected. `$ARGUMENTS`, `$1`, shell injection and `@file` exist in both.
- Rename `_cc-CLAUDEmd.nix` to `_agent-context.nix` and lift the three writing
  rules out of `claude.nix` into a shared attribute set.
- Feed Claude Code as today: context to `CLAUDE.md`, rules as separate files
  under `~/.claude/rules/`, which it loads as memory on its own.
- Feed opencode by concatenating the context and the rules into
  `programs.opencode.context`, which writes `~/.config/opencode/AGENTS.md`.
- Leave skills alone. opencode reads `~/.claude/skills/<name>/SKILL.md`
  directly, so the two skills this repository installs already serve both.
  `programs.opencode.skills` stays unset.

## Capabilities

### New Capabilities

- `agent-config-sharing`: which parts of the agent configuration are written
  once and read by both agents, which mechanism carries each part, and which
  parts cannot be shared.

### Modified Capabilities

- `opencode-provisioning`: gains the commands and the context it did not have.
  The capability currently covers only how opencode is pinned and configured.
- `claude-prose-rules`: `rules-available-in-every-session` is written in terms
  of Claude Code. The rules now have to reach opencode too, and by a different
  mechanism, so the requirement has to say which agents and not only one.
- `mip-init-command`: names `_cc-commands.nix` as the file the command is
  defined in, and `~/.claude/commands/mip:init.md` as the only place it lands.
  Both change.

## Impact

- `modules/programs/dev/vibecoding/_cc-commands.nix` renamed to
  `_agent-commands.nix`, contents unchanged.
- `modules/programs/dev/vibecoding/_cc-CLAUDEmd.nix` renamed to
  `_agent-context.nix`, contents unchanged.
- `modules/programs/dev/vibecoding/_agent-rules.nix` (new), holding the three
  rule texts lifted out of `claude.nix`, including the filler-word list rendered
  from `packages/prose-lint/filler-words.json`.
- `modules/programs/dev/vibecoding/claude.nix`, imports instead of inline rules.
- `modules/programs/dev/vibecoding/opencode.nix`, commands and context added.

Constraints:

- Depends on `pin-opencode-2`. On opencode 1 the `~/.claude/CLAUDE.md` fallback
  exists and would make part of this redundant; on opencode 2 it is gone, and
  `AGENTS.md` is the only always-inlined global channel. Doing this against v1
  would mean designing for behaviour about to be removed.
- The rules reach opencode as one concatenated `AGENTS.md`, not as separate
  documents. opencode 2 has no equivalent of `~/.claude/rules/`: its
  `instructions` key is in the schema but has no consumer, and `references`
  renders a catalogue of paths the model may read rather than inlined text.
- The `prose-lint` PostToolUse hook is not shared. opencode has no hooks; the
  equivalent is a plugin on `tool.execute.after`, which is its own change. Until
  then the typography rules are advice in opencode and enforced in Claude Code.
- `mip:prosegate` tells the agent to read
  `~/.claude/rules/prose-review-amendments.md` by path. That keeps working,
  because Claude Code still writes that file, so the command needs no edit.
