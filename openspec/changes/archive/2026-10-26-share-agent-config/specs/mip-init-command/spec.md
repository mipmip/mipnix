# mip-init-command Specification

## MODIFIED Requirements

### Requirement: mip-init-command-provisioned

The `mip:init` slash command SHALL be defined as an attribute of
`modules/programs/dev/vibecoding/_agent-commands.nix` and therefore deployed to
`~/.claude/commands/mip:init.md` by the `vibecoding-claude-code-config`
home-manager module and to `~/.config/opencode/commands/mip:init.md` by the
`vibecoding-opencode` module, alongside the existing `mip:` commands.

#### Scenario: command deployed by home-manager

- **WHEN** the `vibecoding-claude-code-config` home-manager module is activated
- **THEN** `~/.claude/commands/mip:init.md` SHALL exist as a Nix-store symlink and
  `/mip:init` SHALL be invocable in Claude Code

#### Scenario: command deployed for opencode

- **WHEN** the `vibecoding-opencode` home-manager module is activated
- **THEN** `~/.config/opencode/commands/mip:init.md` SHALL exist as a Nix-store
  symlink and `/mip:init` SHALL be invocable in opencode

#### Scenario: command carries a description

- **WHEN** the command file is read
- **THEN** its frontmatter SHALL carry a `description` so the command appears in the
  slash-command listing, consistent with the other `mip:` commands
- **AND** any frontmatter key only one agent recognises SHALL be ignored by the
  other rather than preventing the command from loading
