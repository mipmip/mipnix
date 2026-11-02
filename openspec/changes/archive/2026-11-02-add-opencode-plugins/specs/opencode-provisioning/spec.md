## ADDED Requirements

### Requirement: OpenCode comes from the official nixpkgs package

The `vibecoding-opencode` module SHALL set `programs.opencode.package` to the
`opencode` package from the repository's pinned `unstable` nixpkgs input. It
SHALL NOT build OpenCode from a separate `anomalyco/opencode` flake input and
SHALL NOT override the package source.

#### Scenario: The official package is selected

- **WHEN** the module is activated
- **THEN** the `opencode` on `PATH` SHALL come from the `unstable` nixpkgs input
- **AND** its reported version SHALL match that input's `opencode` package

#### Scenario: No external OpenCode pin remains

- **WHEN** the flake inputs and the module are inspected
- **THEN** there SHALL be no `opencode` flake input and no source override for
  the OpenCode derivation

#### Scenario: OpenCode follows an unstable update

- **WHEN** `unstable` is updated and the configuration is rebuilt
- **THEN** `opencode --version` SHALL report the version from the updated input
- **AND** the plugin entries SHALL continue to load without a rebuild of their
  own inputs

### Requirement: Global pinned plugins

The module SHALL install `opencode-beans` and `opencode-openspec-sidepanel`
globally through `programs.opencode.settings.plugins`, next to the existing
`opencode-dcp` and `opencode-notifier` entries. Each plugin SHALL load from the
directory produced by its own pinned flake input, and SHALL NOT be fetched from
the network at OpenCode startup.

#### Scenario: Both plugins are available in every project

- **WHEN** OpenCode starts in a project that has no local `.opencode/plugins/`
  directory
- **THEN** `opencode plugin list` SHALL include the Beans and OpenSpec sidepanel
  plugins
- **AND** OpenCode SHALL report no plugin load error

#### Scenario: Existing plugins remain installed

- **WHEN** the new entries are added
- **THEN** `opencode-dcp` and `opencode-notifier` SHALL still be listed and
  functional

#### Scenario: Plugin sources stay pinned

- **WHEN** the upstream plugin repositories change, or the machine starts
  offline
- **THEN** OpenCode SHALL load the revisions recorded in `flake.lock`
- **AND** the plugins SHALL change only after the user updates their flake
  inputs and rebuilds

#### Scenario: An unstable bump does not move the plugins

- **WHEN** only the `unstable` input is updated
- **THEN** the plugin inputs SHALL keep their locked revisions
- **AND** the plugin directories SHALL not be rebuilt from the new nixpkgs

#### Scenario: A project lacks the plugin's data

- **WHEN** a project has no `openspec/` or `.beans/` directory
- **THEN** OpenCode SHALL still start and the plugin's sidebar section SHALL
  report itself unavailable rather than preventing startup
