# opencode-provisioning Specification

## Purpose
How opencode is pinned, built and configured on this machine: which source it
comes from, the workaround its upstream build currently needs, the settings this
repository declares, and the settings it deliberately leaves to opencode itself.

## ADDED Requirements

### Requirement: Pinned To A Tag Of The Upstream Repository
The configuration SHALL take opencode from a flake input pinned to a tag of
`anomalyco/opencode`, and SHALL NOT take it from nixpkgs or from a third-party
nixpkgs fork while opencode 2 is absent from nixpkgs.

#### Scenario: Resolving the package
- **WHEN** the `vibecoding-opencode` home-manager module is evaluated
- **THEN** `programs.opencode.package` SHALL resolve to
  `packages.<system>.opencode` of the pinned input
- **AND** the version SHALL be the tag's version, not the nixpkgs version

#### Scenario: Reproducing a build
- **WHEN** the configuration is built on another machine from the same lock file
- **THEN** the same opencode revision SHALL be built, because the input is
  pinned by `flake.lock` rather than by a branch name

### Requirement: The Build Is Given The Unpruned Source
The configuration SHALL override `src` on the opencode derivation with the
unpruned flake source. Upstream's `nix/node_modules.nix` prunes the source with
a fileset that omits the repository-root `script/` directory, and
`packages/cli/script/build.ts` imports `../../../script/native-arch` from it, so
the upstream flake cannot build its own CLI unaided.

#### Scenario: Building the pinned package
- **WHEN** opencode is built from the pinned input with the override in place
- **THEN** the build SHALL succeed
- **AND** `bin/opencode` SHALL be present and SHALL report the pinned version

#### Scenario: Building without the override
- **WHEN** the same package is built without the override
- **THEN** the build SHALL fail in `buildPhase` with
  `Cannot find module '../../../script/native-arch'`
- **AND** this SHALL be treated as the reason the override exists, recorded as a
  comment beside it

#### Scenario: Upstream repairs the fileset
- **WHEN** a later tag includes the repository-root `script/` directory in the
  fileset
- **THEN** the override SHALL become redundant rather than harmful
- **AND** it MAY be removed once a build without it is shown to succeed

### Requirement: The Input Does Not Follow This Repository's Nixpkgs
The opencode input SHALL NOT be made to follow this repository's `nixpkgs` or
`unstable`, because upstream pins nixpkgs-unstable for the bun version its build
is tested against and the package is uncached in either case. The exception
SHALL be recorded where the input is declared.

#### Scenario: Declaring the input
- **WHEN** the input is added to `flake.nix`
- **THEN** it SHALL carry no `inputs.nixpkgs.follows`
- **AND** a comment SHALL state why, so the exception is not read as an omission

### Requirement: Settings Use The v2 Schema
The configuration SHALL write opencode settings using the v2 key names, so that
no configuration normalization diagnostic is logged at start.

#### Scenario: Keys written
- **WHEN** `~/.config/opencode/opencode.json` is generated
- **THEN** it SHALL use `share`, `update`, `plugins` and `providers`
- **AND** it SHALL NOT use `autoshare`, `autoupdate`, `plugin` or `provider`

#### Scenario: Starting opencode
- **WHEN** opencode starts with the generated configuration
- **THEN** no `configuration normalization diagnostic` SHALL be logged for a key
  this repository declares

### Requirement: Self-Update Is Disabled
The configuration SHALL set `update` to `"disable"`. A store-installed binary
cannot replace itself, and upstream's wrapper, unlike the nixpkgs one, does not
set `OPENCODE_DISABLE_AUTOUPDATE`.

#### Scenario: A newer release exists upstream
- **WHEN** opencode starts while a newer release is published
- **THEN** it SHALL NOT attempt to download or install it
- **AND** updating SHALL remain a change to the pinned tag in `flake.nix`

### Requirement: The Application's Own Configuration File Is Left Alone
The configuration SHALL NOT declare `~/.config/opencode/cli.json`. opencode 2
writes that file itself, migrating the retired `tui.json` into it once, and then
rewrites it whenever an in-application setting changes.

#### Scenario: Changing the theme in the application
- **WHEN** the theme is changed from inside opencode
- **THEN** the change SHALL be written to `cli.json` and SHALL persist
- **AND** it SHALL NOT fail against a read-only Nix store symlink

#### Scenario: The retired TUI file
- **WHEN** the configuration is evaluated
- **THEN** `programs.opencode.tui` SHALL NOT be set
- **AND** `~/.config/opencode/tui.json` SHALL NOT be written by Nix
