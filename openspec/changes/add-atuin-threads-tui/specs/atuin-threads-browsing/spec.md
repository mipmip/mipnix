## ADDED Requirements

### Requirement: att ships with atuin

Every host whose Home Manager configuration imports `pim-atuin` SHALL have the
`att` command on `PATH`. The package SHALL be added in the same module that
configures atuin, so that the tool and the data it reads are activated
together. Hosts that do not import `pim-atuin` SHALL NOT receive `att`.
Activation SHALL stay driven by the module import list; no new enable option
exists.

#### Scenario: Host with atuin gets att

- **WHEN** a host's Home Manager configuration imports `pim-atuin`
- **THEN** `att` SHALL resolve on that user's `PATH`
- **AND** `atuin` SHALL also be on `PATH`, because `att` runs it as a subprocess

#### Scenario: Host without atuin does not get att

- **WHEN** a host does not import `pim-atuin`
- **THEN** `att` SHALL NOT be installed by this change

### Requirement: att is consumed as an external flake input

The package SHALL come from the `atuin-threads-tui` flake input, referenced by
the GitHub URI `github:mipmip/atuin-threads-tui`. The input SHALL declare
`inputs.nixpkgs.follows = "nixpkgs"`. The configuration SHALL NOT reference a
filesystem path or a local checkout, and SHALL NOT carry the source under
`packages/`. Upgrading the tool SHALL be a flake input update, not a source-tree
edit.

#### Scenario: Build without a local checkout

- **WHEN** the flake is evaluated on a host that has no copy of the
  atuin-threads-tui repository
- **THEN** the input SHALL resolve from GitHub
- **AND** the build SHALL NOT require `~/gh.mipmip/atuin-threads-tui`

#### Scenario: Upgrade without touching the module

- **WHEN** the user runs `nix flake update atuin-threads-tui`
- **THEN** the installed `att` SHALL move to the new upstream revision
- **AND** no module or role file SHALL need editing

### Requirement: att leaves atuin's own configuration alone

This change SHALL NOT alter atuin's settings, database, or thread capture. `att`
SHALL run as an ordinary read path over what `atuin threads` reports.

#### Scenario: Atuin settings unchanged

- **WHEN** the Home Manager configuration is built with `att` installed
- **THEN** the generated atuin configuration SHALL be identical to the one
  without `att`
- **AND** `threads.capture` SHALL keep its current value
