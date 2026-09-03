# huphop-tmux-switcher Specification

## Purpose
TBD - created by archiving change add-huphop-tmux-switcher. Update Purpose after archive.

## Requirements

### Requirement: huphop configuration managed by home-manager

The huphop configuration SHALL be generated from Nix and installed at
`~/.config/huphop/config.yaml` via `xdg.configFile`, taking ownership of the file
from the previous hand-written copy. The generated content SHALL reproduce the
current working configuration (base_dir, clone-path template, the `github`
provider with `all_owners: true`, and the `management` and `multiplex` modes),
differing only in the multiplex `switch_command`.

#### Scenario: Config is materialised on switch

- **WHEN** home-manager applies the huphop module
- **THEN** `~/.config/huphop/config.yaml` is a symlink into the Nix store
- **AND** `hup config check` reports the configuration as valid

#### Scenario: Existing working settings preserved

- **WHEN** the generated config is inspected
- **THEN** `base_dir`, `clone_pattern_tpl`, the `github` provider block
  (`username: mipmip`, `clone_protocol: ssh`, `auth.cli: gh`, `all_owners: true`,
  `include_forks: true`), and both mode definitions match the prior working file
- **AND** only the multiplex `switch_command` value differs

### Requirement: tmux binding opens the huphop multiplex switcher

tmux SHALL bind `prefix + G` to a popup that runs
`hup tui --mode multiplex --flatlist`, alongside the existing `prefix + S` smug
popup. The popup SHALL use `popup -E` so it closes when the TUI exits.

#### Scenario: Opening the switcher

- **WHEN** the user presses `prefix + G` inside tmux
- **THEN** a popup opens showing the huphop flat cross-provider repo list
- **AND** the popup closes automatically after a repository is selected and the
  TUI exits

### Requirement: Selecting a repo creates or switches to its org session and repo window

Selecting a repository in the multiplex TUI SHALL clone it first if it is not yet
present, then run the `switch_command` wrapper. The wrapper SHALL place each
repository in a tmux session named for its provider+owner and a window named for
the repository (the session-per-org, window-per-repo model), creating whichever of
the session or window does not yet exist and then switching the current client to
that session and window. Session and window names SHALL be sanitised so that `.`
and `:` cannot break tmux target syntax. The wrapper SHALL only issue tmux server
commands and require no controlling TTY, since it is executed without a shell while
the TUI still owns the terminal.

#### Scenario: First repo of an org

- **WHEN** the selected repo's org session does not exist
- **THEN** the wrapper creates a detached session named `<short>-><owner>` with a
  window named `<repo>` rooted at the repo's local checkout path
- **AND** switches the current client to that session and window

#### Scenario: Additional repo of an existing org

- **WHEN** the org session exists but has no window for the selected repo
- **THEN** the wrapper creates a new window named `<repo>` in that session rooted
  at the checkout path
- **AND** switches the current client to that window

#### Scenario: Repo already open

- **WHEN** the org session and the repo window both already exist
- **THEN** the wrapper creates nothing
- **AND** switches the current client to the existing session and window

#### Scenario: Repo not yet cloned

- **WHEN** the selected repo has no local checkout
- **THEN** huphop clones it before the wrapper runs
- **AND** the resulting checkout path is used as the window's working directory

### Requirement: Collection-aware multiplex session naming
The multiplex `switch_command` SHALL name the tmux session after the active huphop collection when
one is active, and SHALL fall back to the existing `{{.Short}}->{{.OwnerLower}}` naming otherwise.
This requires the huphop input at a version that exposes `{{.Collection}}` in the `switch_command`
template context (huphop ≥ 1.4).

#### Scenario: Inside a collection
- **WHEN** the user switches to a repo while a collection is active
- **THEN** the target tmux session SHALL be named after that collection (creating it if absent),
  with a window per repository

#### Scenario: Outside a collection
- **WHEN** the user switches to a repo with no active collection (flat view or owner drill-down)
- **THEN** the target tmux session SHALL be named `<short>-><ownerLower>` exactly as before

#### Scenario: huphop version prerequisite
- **WHEN** the config is materialised
- **THEN** the huphop package SHALL be a version whose `switch_command` template context includes
  `Collection`, so the `{{if .Collection}}…{{end}}` template evaluates without error

### Requirement: Session/window names remain target-safe
The `hup-tmux-switch` wrapper SHALL accept the resolved session name as its first argument and
SHALL sanitize `:` and `.` out of session and window names so they cannot corrupt tmux's
`session:window.pane` target grammar.

#### Scenario: Collection name with a dot or colon
- **WHEN** a collection name contains `.` or `:`
- **THEN** the wrapper SHALL replace those characters before using the name as a tmux target,
  so the switch does not fail

#### Scenario: Existing sessions unchanged
- **WHEN** switching outside a collection
- **THEN** the sanitized session name SHALL equal the current `<short>-><ownerLower>` value, so
  no existing session behavior changes
