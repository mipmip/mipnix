## Purpose

Makes the `nivis` CLI — my own tool for driving Terraform/OpenTofu provider
resources as first-class Nix values — part of the infrastructure toolchain on
devbox hosts, upgradeable with nothing more than a flake update.

## ADDED Requirements

### Requirement: nivis Present In The Infrastructure Toolchain
The system SHALL install the `nivis` command on every host that carries the
devbox role, alongside the other infrastructure-as-code tools.

#### Scenario: Invoking nivis on a devbox host
- **WHEN** a user on a host with the devbox role runs `nivis --version` in any shell
- **THEN** the command SHALL resolve without a `nix run` or a manual PATH entry
- **AND** it SHALL report the version of the locked upstream revision

#### Scenario: Host without the devbox role
- **WHEN** a host does not carry the devbox role
- **THEN** `nivis` SHALL NOT be installed on it

### Requirement: Upstream Tracked By A Moving Reference
The system SHALL reference nivis by a remote flake URI that advances, so that a
flake update is the entire upgrade procedure. The reference SHALL NOT be a
version tag, and SHALL NOT be a filesystem path.

#### Scenario: Upgrading to a newer nivis
- **WHEN** the maintainer runs `nix flake update nivis` and rebuilds
- **THEN** the locked revision SHALL advance to the newest upstream revision
- **AND** no file in the repository SHALL need editing to pick up that version

#### Scenario: Building without a local working copy
- **WHEN** the flake is evaluated on a host that has no local clone of nivis
- **THEN** the build SHALL succeed, resolving nivis from its remote URI

### Requirement: nivis Builds Against The Repository nixpkgs
The system SHALL build nivis from the same nixpkgs revision as the rest of the
configuration, so it shares one toolchain and closure and adds no further
nixpkgs revision to the dependency graph.

#### Scenario: Dependency graph after adding nivis
- **WHEN** the lock file is inspected after the input is added
- **THEN** it SHALL contain no nixpkgs revision that was absent before the change

#### Scenario: nivis fails to build on the repository nixpkgs
- **WHEN** a flake update moves nivis to a revision that does not build against
  the configuration's nixpkgs
- **THEN** the failure SHALL surface at build time rather than producing a
  silently divergent toolchain

### Requirement: Command-Line Interface Only
The system SHALL install only the nivis CLI. The tutorial scaffolder and the
in-repo fake providers that upstream also publishes SHALL NOT be installed, and
nivis SHALL NOT require any managed configuration file.

#### Scenario: What lands on the host
- **WHEN** the installed package's contents are inspected
- **THEN** `nivis` SHALL be present
- **AND** `nivistutor` and the fake provider binaries SHALL be absent

#### Scenario: First run on a fresh host
- **WHEN** nivis is run on a host where it has never run before
- **THEN** it SHALL start without the configuration requiring a file managed by
  this repository
