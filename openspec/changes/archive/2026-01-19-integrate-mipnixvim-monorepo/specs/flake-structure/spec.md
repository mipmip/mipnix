# flake-structure Specification

## Purpose
Defines the organizational structure and conventions for the NixOS flake configuration, including how packages, modules, and dependencies are organized and integrated within the monorepo.

## ADDED Requirements

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
The system SHALL prefer local package integration over external GitHub-based flake inputs for personally-maintained packages to reduce dependency complexity and development friction.

#### Scenario: Personal package dependency
- **WHEN** a package is personally maintained (e.g., mipmip/* repositories)
- **THEN** integration as a local package SHALL be preferred over external flake input
- **AND** external flake inputs SHALL be reserved for third-party dependencies
- **AND** the package MAY maintain an external GitHub repository for distribution purposes

### Requirement: Flake Input Management
The system SHALL maintain flake inputs in the inputs section of flake.nix, with each input properly documented and version-pinned through flake.lock.

#### Scenario: Removing deprecated input
- **WHEN** a package is migrated from external input to local package
- **THEN** the external input SHALL be removed from flake.nix inputs section
- **AND** flake.lock SHALL be updated to remove the dependency
- **AND** all references to `inputs.<package-name>` SHALL be updated to use local package references
