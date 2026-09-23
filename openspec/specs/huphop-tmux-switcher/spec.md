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

Every window the wrapper CREATES SHALL be arranged into three panes: one pane
occupying the left 50% of the window's width, and the remaining right 50% split
into a top and a bottom pane of equal height.

```
┌──────────────────┬──────────────────┐
│                  │       top        │
│       left       ├──────────────────┤
│                  │      bottom      │
└──────────────────┴──────────────────┘
         50%                50%
```

All three panes SHALL be plain interactive shells with no command run in them,
and all three SHALL start in the repo's local checkout path. The left pane SHALL
be the window's active pane when the client is switched to it.

The wrapper SHALL NOT alter the pane arrangement of a window it did not create in
this invocation, so re-selecting an already-open repository leaves that window's
panes exactly as the user left them.

#### Scenario: First repo of an org

- **WHEN** the selected repo's org session does not exist
- **THEN** the wrapper creates a detached session named `<short>-><owner>` with a
  window named `<repo>` rooted at the repo's local checkout path
- **AND** that window is arranged into the three-pane layout with the left pane active
- **AND** switches the current client to that session and window

#### Scenario: Additional repo of an existing org

- **WHEN** the org session exists but has no window for the selected repo
- **THEN** the wrapper creates a new window named `<repo>` in that session rooted
  at the checkout path
- **AND** that window is arranged into the three-pane layout with the left pane active
- **AND** switches the current client to that window

#### Scenario: Repo already open

- **WHEN** the org session and the repo window both already exist
- **THEN** the wrapper creates nothing
- **AND** the existing window's panes are left untouched, however many there are
- **AND** switches the current client to the existing session and window

#### Scenario: Repo not yet cloned

- **WHEN** the selected repo has no local checkout
- **THEN** huphop clones it before the wrapper runs
- **AND** the resulting checkout path is used as the window's working directory
- **AND** as the starting directory of all three panes

#### Scenario: Panes start as shells in the checkout

- **WHEN** a window has just been created by the wrapper
- **THEN** each of its three panes is an interactive shell with no command issued
  into it
- **AND** each pane's starting directory is the repo's local checkout path

#### Scenario: Layout survives a window resize

- **WHEN** a window created by the wrapper is resized
- **THEN** the panes keep their proportions — left at about half the width, and the
  right column split about evenly in height

#### Scenario: User rearranges a window and returns to it

- **WHEN** the user closes or resizes panes in a window the wrapper created, and
  later selects that same repository again
- **THEN** the wrapper does not re-split, re-balance, or re-focus that window
- **AND** only switches the current client to it

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

### Requirement: Clones are colocated jj checkouts by default

The generated huphop configuration SHALL set the global `clone_vcs` to `jj`, so every
repository huphop clones (from the management TUI or from the multiplex switcher's
clone-then-switch path) is created with `jj git clone --colocate`. A real top-level
`.git` remains, so `hup sync` and every git tool keep working on the checkout.

The setting is global rather than per-provider: there is a single `github` provider, and
a global default also covers any provider added later. Per-provider `clone_vcs` and
per-repo `vcs_rules` stay available if one repository ever needs plain git.

This requires the huphop input at a version whose config schema accepts `clone_vcs`
(huphop >= 1.1), and `jj` on the PATH of the process running `hup`, since the clone fails with
an actionable error otherwise. `jj` is already installed by the `pim-git` home-manager
module.

The `hup-tmux-switch` wrapper SHALL NOT change: the VCS choice belongs to huphop's clone
engine, which runs before `switch_command` is executed, so the tmux wiring stays agnostic
to how the checkout was created.

#### Scenario: Cloning a repository not yet present

- **WHEN** a repository without a local checkout is selected in either TUI mode
- **THEN** huphop clones it with `jj git clone --colocate`
- **AND** the checkout contains both a `.jj` and a top-level `.git` directory

#### Scenario: Switching into a freshly cloned repo

- **WHEN** the multiplex switcher clones a repository and then runs `switch_command`
- **THEN** the wrapper receives the same `{{.Target}}` checkout path as before
- **AND** the three panes open in that path, where `jj` commands and the jj prompt work

#### Scenario: Existing checkouts untouched

- **WHEN** a repository already has a local checkout cloned with plain git
- **THEN** huphop clones nothing and the checkout is left as it is
- **AND** selecting it in the multiplex switcher behaves exactly as before

#### Scenario: Config stays valid

- **WHEN** home-manager materialises `~/.config/huphop/config.yaml`
- **THEN** `hup config check` reports the configuration as valid with `clone_vcs: jj`
