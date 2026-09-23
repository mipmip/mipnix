# specgetty-tmux-popup Specification

## Purpose
TBD - created by archiving change add-specgetty-tmux-popup. Update Purpose after archive.

## Requirements

### Requirement: specgetty comes from the speclib input at v0.3.0 or later

The `specgetty` flake input SHALL name `github:speclib/specgetty`, the
repository's current owner, rather than the `mipmip` URL that only resolves
through GitHub's rename redirect. It SHALL be locked to v0.3.0 or later, the
first version whose default view resolves the project from the working
directory.

The home-manager module SHALL keep taking the package from
`inputs.specgetty.packages.<system>.specgetty`, which that version still
exposes.

#### Scenario: The input names the current owner

- **WHEN** `flake.nix` is inspected
- **THEN** the `specgetty` input URL SHALL be `github:speclib/specgetty`

#### Scenario: The installed version has the new startup behaviour

- **WHEN** `spg --version` is run after the update
- **THEN** it SHALL report 0.3.0 or later
- **AND** `spg --help` SHALL list `--view` and SHALL NOT list `--zoom`

#### Scenario: The existing configuration keeps working

- **WHEN** the updated specgetty reads `~/.config/specgetty/config.yml`
- **THEN** the existing `scandirs` and `followsymlinks` keys SHALL be accepted
  unchanged
- **AND** the new optional `edit_command` and `change_fields` keys SHALL be
  absent without error

### Requirement: prefix + A opens specgetty at the pane's path

The tmux bind registry SHALL carry an entry binding `prefix + A` to a popup that
runs `spg` with the pane's current path as its working directory, at 90% of the
client's width and height. The entry SHALL belong to the tools group, so it is
listed with the other launchers in the `prefix + ?` menu.

The popup SHALL run `spg` directly, with no launcher script and no flags, since
`--view single` is that version's default and resolves the project by walking up
from the working directory.

#### Scenario: Opening it inside a project

- **WHEN** the user presses `prefix + A` in a pane whose directory is inside an
  OpenSpec project
- **THEN** a popup opens showing that project
- **AND** the project is the one found by walking up from the pane's directory,
  not the directory tmux was started in

#### Scenario: Opening it from a subdirectory

- **WHEN** the pane is several directories below the project root
- **THEN** the popup SHALL still open that project

#### Scenario: Opening it outside any project

- **WHEN** the pane's directory has no `openspec/` directory at or above it
- **THEN** specgetty SHALL offer its project picker
- **AND** the popup SHALL NOT close immediately, so nothing flashes past unread

#### Scenario: Closing the popup

- **WHEN** the user quits specgetty
- **THEN** the popup SHALL close and return to the pane

### Requirement: The entry is declared through the registry

The binding SHALL be declared as a single `customBinds` entry, emitting both the
`bind` line and the menu entry, in the same way as every other custom binding.
It SHALL NOT be written as a loose `bind` line in `extraConfig`.

#### Scenario: The key is bound and listed

- **WHEN** the generated tmux configuration is inspected
- **THEN** it SHALL contain a `bind A` line running the popup
- **AND** the `prefix + ?` menu SHALL contain an `A` entry with its description

#### Scenario: The entry fires from the menu

- **WHEN** the menu is open and `A` is pressed
- **THEN** the specgetty popup SHALL open, as it does from `prefix + A`

#### Scenario: No other binding changes

- **WHEN** the bindings are compared with those from before the change
- **THEN** only `A` SHALL be added
- **AND** every other key SHALL keep the command it had
