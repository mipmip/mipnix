## ADDED Requirements

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
