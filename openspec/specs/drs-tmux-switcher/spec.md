# drs-tmux-switcher Specification

## Purpose
TBD - created by archiving change add-drs-tmux-switcher. Update Purpose after archive.
## Requirements
### Requirement: tmux keybinding launches the drs multiplex popup
The tmux configuration SHALL bind `prefix + R` to open a popup running `drs --multiplex`.

#### Scenario: Open the popup
- **WHEN** the user presses `prefix + R` in tmux
- **THEN** tmux SHALL open a `-E` popup running `drs --multiplex`

#### Scenario: Popup closes on quit
- **WHEN** `drs` exits (after a selection or cancel)
- **THEN** the popup SHALL close automatically

### Requirement: drs switch_command routes selection into the dirtyrepos session
The drs `config.yml` SHALL set `switch_command` to invoke the `drs-switch` wrapper with the
selected repo's working directory.

#### Scenario: Enter runs the switch command
- **WHEN** the user presses Enter on a repo in `drs --multiplex`
- **THEN** drs SHALL run `switch_command` with the selected repo's working directory and then quit

### Requirement: drs-switch creates or selects a dirtyrepos session
The `drs-switch` wrapper SHALL ensure a tmux session named `dirtyrepos` exists, creating it
only if absent.

#### Scenario: Session does not exist
- **WHEN** `drs-switch` runs and no `dirtyrepos` session exists
- **THEN** it SHALL create a new detached session named `dirtyrepos` with a first window for the selected repo

#### Scenario: Session already exists
- **WHEN** `drs-switch` runs and a `dirtyrepos` session already exists
- **THEN** it SHALL NOT create a second session

### Requirement: drs-switch creates or selects a per-repo window
The `drs-switch` wrapper SHALL ensure a window named after the selected repo's directory
basename exists in the `dirtyrepos` session, creating it only if absent, and SHALL start the
window in the repo's directory.

#### Scenario: Window does not exist
- **WHEN** the `dirtyrepos` session has no window matching the repo basename
- **THEN** `drs-switch` SHALL create a new window named after the basename, started in the repo directory

#### Scenario: Window already exists
- **WHEN** the `dirtyrepos` session already has a window matching the repo basename
- **THEN** `drs-switch` SHALL reuse that window and SHALL NOT create a duplicate

#### Scenario: Focus the target window
- **WHEN** the session and window are ensured
- **THEN** `drs-switch` SHALL switch the client to `dirtyrepos:<basename>`

### Requirement: Basename collisions do not error
When two selected repos share the same directory basename, `drs-switch` SHALL route them to
the same window without error; disambiguation is out of scope for this change.

#### Scenario: Two repos share a basename
- **WHEN** two dirty repos have the same directory basename
- **THEN** `drs-switch` SHALL reuse a single window for both and SHALL NOT error

