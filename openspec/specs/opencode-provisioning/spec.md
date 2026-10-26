# opencode-provisioning Specification

## Purpose
TBD - created by archiving change share-agent-config. Update Purpose after archive.

## Requirements

### Requirement: Commands Are Provisioned
The `vibecoding-opencode` module SHALL give `programs.opencode.commands` the
shared command set, so the `mip:` commands are invocable in opencode.

#### Scenario: Commands written
- **WHEN** the module is activated
- **THEN** every attribute of the shared command set SHALL exist as
  `~/.config/opencode/commands/<name>.md` as a Nix-store symlink
- **AND** `programs.opencode.commands` SHALL NOT be an empty attribute set

#### Scenario: The same text as Claude Code
- **WHEN** a command file under `~/.config/opencode/commands/` is compared with
  the file of the same name under `~/.claude/commands/`
- **THEN** the contents SHALL be identical, because both come from the same Nix
  attribute

### Requirement: Global Context Is Provisioned
The `vibecoding-opencode` module SHALL set `programs.opencode.context` to the
shared global context followed by the shared writing rules, so opencode receives
both in `~/.config/opencode/AGENTS.md`.

#### Scenario: The file is written
- **WHEN** the module is activated
- **THEN** `~/.config/opencode/AGENTS.md` SHALL exist as a Nix-store symlink
- **AND** it SHALL contain the global context and every writing rule

#### Scenario: A rule is changed
- **WHEN** a writing rule is changed in its single Nix definition and the
  configuration is rebuilt
- **THEN** `AGENTS.md` SHALL carry the new text
- **AND** the change SHALL have required no edit inside the opencode module

### Requirement: Skills Are Not Declared For opencode
The `vibecoding-opencode` module SHALL leave `programs.opencode.skills` unset.
opencode reads `~/.claude/skills/<name>/SKILL.md` itself, so declaring the
skills again would write a second copy for no gain.

#### Scenario: Skills available without declaration
- **WHEN** opencode starts and a skill is installed under `~/.claude/skills/`
- **THEN** the skill SHALL be listed as available in opencode
- **AND** no copy of it SHALL exist under `~/.config/opencode/skills/`
