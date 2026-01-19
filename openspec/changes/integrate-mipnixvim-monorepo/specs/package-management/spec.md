# package-management Specification

## Purpose
Defines how packages are built, referenced, and consumed within the NixOS configuration, including the relationship between local packages and system modules.

## ADDED Requirements

### Requirement: Local Package References
The system SHALL enable modules to reference locally-defined packages using `inputs.self.packages.${system}.<package-name>` syntax.

#### Scenario: Module consuming local package
- **WHEN** a Home Manager or NixOS module needs to install a local package
- **THEN** it SHALL reference the package using `inputs.self.packages.${system}.<package-name>`
- **AND** the module SHALL receive `system` and `inputs` as parameters
- **AND** the package SHALL be added to `home.packages` or `environment.systemPackages` as appropriate

### Requirement: Package Independence
The system SHALL ensure that local packages can be built and tested independently of the main system configuration.

#### Scenario: Standalone package build
- **WHEN** a package exists in `packages/<package-name>/`
- **THEN** it SHALL be buildable using `nix build ./packages/<package-name>`
- **AND** it SHALL maintain its own flake.nix with appropriate inputs and outputs
- **AND** it SHALL NOT depend on the parent monorepo for build-time dependencies

### Requirement: Package Parameter Passing
The system SHALL pass necessary build parameters (pkgs, system, lib) to local packages through their import or flake interface.

#### Scenario: Package receiving build parameters
- **WHEN** a local package is imported in perSystem
- **THEN** it SHALL receive at minimum `pkgs` and `system` parameters
- **AND** additional parameters MAY be passed based on package requirements
- **AND** the package SHALL use these parameters for architecture-specific builds

### Requirement: Cross-Package Consistency
The system SHALL use consistent nixpkgs versions across all local packages and system configuration to avoid version conflicts.

#### Scenario: Shared nixpkgs version
- **WHEN** multiple packages are built within the monorepo
- **THEN** they SHALL use the same nixpkgs input version
- **AND** package flake.nix files MAY define their own nixpkgs input for standalone builds
- **AND** the parent flake SHALL override package nixpkgs when building integrated packages
