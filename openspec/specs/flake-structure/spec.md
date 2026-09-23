# flake-structure Specification

## Purpose
TBD - created by archiving change integrate-mipnixvim-monorepo. Update Purpose after archive.

## Requirements

### Requirement: Monorepo Package Organization
The system SHALL organize internal packages under a dedicated `packages/` directory at the repository root to separate them from system configuration modules.

#### Scenario: Local package location
- **WHEN** an internal package is integrated into the monorepo
- **THEN** it SHALL be placed in `packages/<package-name>/`
- **AND** the package SHALL maintain its own flake.nix for standalone buildability
- **AND** the package SHALL be exposed through the main flake's package outputs

### Requirement: Local Package Outputs
The system SHALL expose internal packages through flake-parts perSystem package outputs, making them available as `packages.${system}.<package-name>`.

#### Scenario: Package exposed via flake outputs
- **WHEN** a package exists in `packages/<package-name>/`
- **THEN** it SHALL be exposed as `packages.${system}.<package-name>` in the flake outputs
- **AND** it SHALL be importable by system modules using `inputs.self.packages.${system}.<package-name>`
- **AND** it SHALL support all architectures defined in the flake's systems list

### Requirement: External Input Minimization
The system SHALL decide between a local package and an external flake input by
how the package is developed, not by who maintains it. Components co-developed
with this repository — changed in the same commit as the configuration that
consumes them, with no release cycle of their own — SHALL be integrated as local
packages under `packages/`. Standalone tools that carry their own versioning and
release cycle SHALL be consumed as external flake inputs, whether they are
personally maintained or third-party, so that upgrading them is a flake update
rather than a source-tree edit.

#### Scenario: Co-developed component
- **WHEN** a package is edited in lockstep with the modules that consume it and
  publishes no releases of its own
- **THEN** it SHALL be integrated as a local package under `packages/`
- **AND** it SHALL be referenced through `inputs.self.packages.${system}.<name>`

#### Scenario: Personal package dependency
- **WHEN** a package is personally maintained (e.g., `mipmip/*` repositories) and
  is developed in its own repository with its own release cycle
- **THEN** it SHALL be consumed as an external flake input rather than vendored
  into `packages/`
- **AND** the input SHALL be referenced by a remote URI, never a filesystem path,
  so the configuration builds on hosts without a local working copy
- **AND** the input SHOULD declare `inputs.nixpkgs.follows` unless it is known
  not to build against this repository's nixpkgs

### Requirement: Flake Input Management
The system SHALL maintain flake inputs in the inputs section of flake.nix, with each input properly documented and version-pinned through flake.lock.

#### Scenario: Removing deprecated input
- **WHEN** a package is migrated from external input to local package
- **THEN** the external input SHALL be removed from flake.nix inputs section
- **AND** flake.lock SHALL be updated to remove the dependency
- **AND** all references to `inputs.<package-name>` SHALL be updated to use local package references
