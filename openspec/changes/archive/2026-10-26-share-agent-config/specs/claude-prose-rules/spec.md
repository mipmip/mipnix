# claude-prose-rules Specification

## MODIFIED Requirements

### Requirement: Rules Available In Every Session
The system SHALL make the writing rules available in every project to every
coding agent configured on this machine, not to Claude Code alone. For Claude
Code they SHALL be separate documents grouped by concern, so a rule can be
added, changed or removed on its own. For an agent with no mechanism for
separate rule documents they SHALL be inlined into that agent's global context
file, under one heading per concern, so the grouping survives in the text even
where it cannot survive in the filesystem.

The rules SHALL be defined once, in Nix, and rendered per agent. No agent SHALL
carry a hand-maintained copy.

#### Scenario: Starting a session in any repository
- **WHEN** Claude Code starts in any directory on this machine
- **THEN** the writing rules SHALL be present in its memory without the user
  asking for them
- **AND** each concern SHALL be a separate document

#### Scenario: Starting an opencode session in any repository
- **WHEN** opencode starts in any directory on this machine
- **THEN** the writing rules SHALL be present in its context without the user
  asking for them
- **AND** each concern SHALL appear under its own heading in `AGENTS.md`

#### Scenario: A rule is changed
- **WHEN** a rule's text is changed in its single Nix definition
- **AND** the configuration is rebuilt
- **THEN** the change SHALL appear in every agent that receives the rules
- **AND** no agent SHALL still be serving the previous text

#### Scenario: Enforcement is not uniform
- **WHEN** the typography rules are relied on
- **THEN** they SHALL be understood as enforced in Claude Code, where a hook
  fails the write, and as advisory in an agent that has no such hook
- **AND** the difference SHALL be recorded rather than left implied, because the
  point of enforcement is that the rules do not depend on the model remembering
  them
