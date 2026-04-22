## ADDED Requirements

### Requirement: Commands split into RUNME.d files
The system SHALL organize RUNME.sh commands into separate files under `RUNME.d/`, grouped by concern, and auto-sourced by the v2.0.0 boilerplate.

#### Scenario: All commands available after split
- **WHEN** user runs `./RUNME.sh` with no arguments
- **THEN** all 15 commands appear in the usage output, identical to before the split

#### Scenario: Helpers sourced before commands
- **WHEN** RUNME.d/ files are sourced in alphabetical order
- **THEN** `00-helpers.sh` is sourced first, making shared functions available to all command files

### Requirement: v2.0.0 boilerplate
The system SHALL use the RUNME.sh v2.0.0 boilerplate which includes `RUNME_DIR` resolution and `RUNME.d/` auto-sourcing.

#### Scenario: Boilerplate upgraded
- **WHEN** RUNME.sh is loaded
- **THEN** the shebang is `#!/usr/bin/env bash`, the boilerplate includes `RUNME_DIR` resolution and the `RUNME.d/` sourcing loop
