# nebula-ssh-tmux-picker Specification

## Purpose
TBD - created by archiving change add-nebula-ssh-tmux-picker. Update Purpose after archive.

## Requirements

### Requirement: Prefix+H host picker binding

The `pim-tmux` home-manager module SHALL bind `Prefix + H` to a popup that lists
every nebula host and lets the user pick one with `fzf`. The picker SHALL be
non-destructive on cancel: pressing Escape (or an empty selection) SHALL close the
popup and change nothing.

#### Scenario: Opening the picker

- **WHEN** the user presses `Prefix + H` inside tmux
- **THEN** a popup opens showing an `fzf` list of nebula hosts derived from the
  `flake.nebulaNodes` registry

#### Scenario: Cancelling the picker

- **WHEN** the picker is open and the user presses Escape without selecting a host
- **THEN** the popup closes and no session, window, or SSH connection is created

### Requirement: Complete host list from the registry

The picker's host list SHALL be baked at build time from `self.lib.nebulaHosts`
(derived from `flake.nebulaNodes`) and SHALL include every active nebula node —
both servers and laptops — with no runtime certificate decryption.

#### Scenario: Servers and laptops both listed

- **WHEN** the picker is opened
- **THEN** the list SHALL include the server nodes (`durer`, `dapperehaan`, `hurry`,
  `harry`) and the laptop nodes (`lavendel`, `cichorei`, `zonnehoed`, `doornappel`)

#### Scenario: Picking doornappel from another laptop

- **WHEN** the user opens the picker on `cichorei` and selects `doornappel`
- **THEN** a `doornappel` window SHALL be opened in the `nebula-prive` session
  running `ssh pim@192.168.100.15`

#### Scenario: Non-mesh hosts excluded

- **WHEN** the picker is opened
- **THEN** the list SHALL NOT include hosts absent from `flake.nebulaNodes`
  (e.g. `peterspav`, whose nebula role is disabled, or `_lego2`, excluded from the
  module tree)

### Requirement: Connect into a per-host window in the nebula-prive session

On selecting a host, the picker SHALL ensure a dedicated tmux session named
`nebula-prive` exists, open (or reuse) a window named after the selected host that
runs `ssh pim@<ip>` for that host's registry IP, and switch the client to it.
Selecting the same host again SHALL reuse its existing window rather than opening a
duplicate.

#### Scenario: First connection to a host

- **WHEN** the user selects `durer` and no `nebula-prive` session exists
- **THEN** a detached `nebula-prive` session SHALL be created, a window named
  `durer` SHALL be opened running `ssh pim@192.168.100.12`, and the client SHALL be
  switched to `nebula-prive:durer`

#### Scenario: Reconnecting to an already-open host

- **WHEN** the user selects `durer` and a `durer` window already exists in the
  `nebula-prive` session
- **THEN** the client SHALL switch to the existing `nebula-prive:durer` window and
  no second `durer` window SHALL be created

#### Scenario: Second host joins the same session

- **WHEN** the user selects `hurry` while the `nebula-prive` session already holds a
  `durer` window
- **THEN** a new `hurry` window SHALL be added to the same `nebula-prive` session
  and the client SHALL switch to it
