# flake-structure Specification

## Purpose
Defines the organizational structure and conventions for the NixOS flake configuration, including how packages, modules, and dependencies are organized and integrated within the monorepo.

## ADDED Requirements

### Requirement: Monorepo Package Configuration Organization
The system SHALL organize internal package configurations under a dedicated `packages/` directory at the repository root to separate them from system configuration modules.

#### Scenario: Local package configuration location
- **WHEN** an internal package configuration is integrated into the monorepo
- **THEN** it SHALL be placed in `packages/<package-name>/config/` (or `packages/<package-name>/` for non-config files)
- **AND** the package SHALL be built directly by the root flake when appropriate
- **AND** the package SHALL be exposed through the main flake's package outputs

### Requirement: Direct Package Building
The system SHALL build packages directly in the root flake's perSystem when the package is a configuration for an external tool (like nixvim) rather than requiring a separate flake.nix.

#### Scenario: Package built in root flake
- **WHEN** a package is primarily a configuration (not a standalone derivation)
- **THEN** it SHALL be built directly in root flake's perSystem
- **AND** it SHALL use appropriate nixpkgs version for the build tool
- **AND** it SHALL leverage import-tree or similar tools for modular configuration loading
- **AND** it SHALL NOT require its own flake.nix

### Requirement: Library-based Package Integration
The system SHALL use external package builders (like nixvim) as libraries rather than as separate flake inputs when integrating configurations.

#### Scenario: Using external builder as library
- **WHEN** integrating a configuration that uses an external builder
- **THEN** the external builder SHALL be added as a direct input to root flake
- **AND** the builder SHALL be used as a library in perSystem
- **AND** configuration files SHALL be stored in packages/<name>/config/
- **AND** the builder's API SHALL be used directly (e.g., makeNixvimWithModule)

### Requirement: Local Package Outputs
The system SHALL expose internal packages through flake-parts perSystem package outputs, making them available as `packages.${system}.<package-name>`.

#### Scenario: Package exposed via flake outputs
- **WHEN** a package exists in `packages/<package-name>/`
- **THEN** it SHALL be exposed as `packages.${system}.<package-name>` in the flake outputs
- **AND** it SHALL be importable by system modules using `inputs.self.packages.${system}.<package-name>`
- **AND** it SHALL support all architectures defined in the flake's systems list

### Requirement: External Input Minimization
The system SHALL prefer direct integration over separate flake inputs for personally-maintained configurations to reduce dependency complexity and development friction.

#### Scenario: Personal configuration dependency
- **WHEN** a configuration is personally maintained (e.g., mipvim neovim config)
- **THEN** direct integration into root flake SHALL be preferred over local flake input
- **AND** the builder tool (e.g., nixvim) SHALL be a direct input instead
- **AND** configuration SHALL be stored in packages/<name>/config/
- **AND** external flake inputs SHALL be reserved for third-party packages/tools

### Requirement: Flake Input Management
The system SHALL maintain flake inputs in the inputs section of flake.nix, with each input properly documented and version-pinned through flake.lock.

#### Scenario: Removing deprecated local flake input
- **WHEN** a configuration is migrated from local flake input to direct integration
- **THEN** the local flake input SHALL be removed from flake.nix inputs section
- **AND** the builder tool inputs SHALL be added to root flake inputs
- **AND** flake.lock SHALL be updated to reflect the changes
- **AND** all references to the old input SHALL be updated to use self.packages
