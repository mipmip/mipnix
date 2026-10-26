# agent-config-sharing Specification

## Purpose
Which parts of the agent configuration are written once and read by both Claude
Code and opencode, which mechanism carries each part, and which parts cannot be
shared and why.

## ADDED Requirements

### Requirement: Commands Are Defined Once
The slash commands SHALL be defined once, as a single Nix attribute set, and
SHALL be given to both agents without per-agent editing of the command text.

#### Scenario: A command is added
- **WHEN** an attribute is added to the shared command set
- **AND** the configuration is rebuilt
- **THEN** the command SHALL appear in Claude Code under `~/.claude/commands/`
- **AND** the command SHALL appear in opencode under
  `~/.config/opencode/commands/`
- **AND** both SHALL answer to the same slash name

#### Scenario: A namespaced command name
- **WHEN** the attribute is named with a colon, such as `mip:ship`
- **THEN** the file SHALL be written as `mip:ship.md` in both locations
- **AND** `/mip:ship` SHALL invoke it in both agents, because opencode derives a
  command's name by stripping the directory prefix and the `.md` suffix from its
  path and matches the text up to the first whitespace after the slash

#### Scenario: Frontmatter one agent does not know
- **WHEN** a command carries frontmatter the other agent has no key for, such as
  `argument-hint`
- **THEN** that key SHALL be ignored rather than rejected
- **AND** the command SHALL still load

#### Scenario: Arguments and interpolation
- **WHEN** a command uses `$ARGUMENTS`, a positional `$1`, a shell injection or
  an `@file` reference
- **THEN** it SHALL behave equivalently in both agents, because both implement
  all four

### Requirement: Global Context Is Defined Once
The global context SHALL be defined once and SHALL reach both agents, at
`~/.claude/CLAUDE.md` for Claude Code and `~/.config/opencode/AGENTS.md` for
opencode.

#### Scenario: Starting a session in any repository
- **WHEN** either agent starts in any directory on this machine
- **THEN** the same global context SHALL be present in its context
- **AND** neither file SHALL be maintained by hand

#### Scenario: Relying on a fallback is not sufficient
- **WHEN** opencode 2 is in use
- **THEN** the context SHALL be written to `AGENTS.md` explicitly
- **AND** the configuration SHALL NOT rely on a `~/.claude/CLAUDE.md` fallback,
  because opencode 2 reads only `AGENTS.md` and the fallback that existed in
  opencode 1 is gone

### Requirement: Writing Rules Reach Both Agents
The writing rules SHALL be defined once and SHALL reach both agents. The
mechanism differs by agent and the difference SHALL be recorded, because one
agent receives them as separate documents and the other does not.

#### Scenario: Rules in Claude Code
- **WHEN** Claude Code starts
- **THEN** each rule SHALL be a separate document under `~/.claude/rules/`
- **AND** each SHALL be loaded as memory without the user asking

#### Scenario: Rules in opencode
- **WHEN** opencode starts
- **THEN** the rules SHALL be present in `AGENTS.md`, each under its own heading
- **AND** they SHALL be inlined rather than offered as paths the agent may read

#### Scenario: Why the rules are not a directory in opencode
- **WHEN** a mechanism for separate rule documents in opencode is looked for
- **THEN** none SHALL be used, because `instructions` is declared in opencode's
  config schema with no consumer and `references` renders a catalogue of paths
  rather than inlined text
- **AND** this SHALL be revisited if opencode gains a rules directory or makes
  `instructions` load

### Requirement: Skills Are Shared Through The Filesystem
The skills SHALL be installed once, under `~/.claude/skills/`, and SHALL NOT be
declared a second time for opencode. opencode reads that directory itself.

#### Scenario: A skill is installed
- **WHEN** a skill is added to `programs.claude-code.skills`
- **THEN** it SHALL be available in Claude Code
- **AND** it SHALL be available in opencode without any opencode-side
  declaration, because opencode scans each `.claude` root's `skills` directory
  for `SKILL.md`

#### Scenario: Skills are not declared twice
- **WHEN** the configuration is evaluated
- **THEN** `programs.opencode.skills` SHALL be unset
- **AND** no second copy of a skill SHALL be written under
  `~/.config/opencode/skills/`

### Requirement: What Is Deliberately Not Shared
The configuration SHALL NOT attempt to share the parts that have no counterpart
in the other agent, and the gaps SHALL be recorded so they are not mistaken for
oversights.

#### Scenario: The prose-lint hook
- **WHEN** the configuration is evaluated
- **THEN** the `prose-lint` check SHALL remain a Claude Code `PostToolUse` hook
- **AND** opencode SHALL have no equivalent until a plugin on
  `tool.execute.after` is written
- **AND** the typography rules SHALL therefore be enforced in Claude Code and
  advisory in opencode

#### Scenario: Agent settings with no counterpart
- **WHEN** settings such as the status line or `includeCoAuthoredBy` are
  considered for sharing
- **THEN** they SHALL remain Claude Code settings, because opencode has no
  matching key
