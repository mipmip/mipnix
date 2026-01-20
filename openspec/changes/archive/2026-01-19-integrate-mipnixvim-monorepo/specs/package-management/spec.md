# package-management Specification

## Purpose
Defines how packages are built, referenced, and consumed within the NixOS configuration, including the relationship between local packages and system modules.

## ADDED Requirements

### Requirement: Local Package References
The system SHALL enable modules to reference locally-built packages using `inputs.self.packages.${system}.<package-name>` syntax.

#### Scenario: Module consuming locally-built package
- **WHEN** a Home Manager or NixOS module needs to install a locally-built package
- **THEN** it SHALL reference the package using `inputs.self.packages.${system}.<package-name>`
- **AND** the module SHALL receive `system` and `inputs` as parameters
- **AND** the package SHALL be added to `home.packages` or `environment.systemPackages` as appropriate

### Requirement: Configuration-based Package Building
The system SHALL support building packages directly from configuration files when appropriate, without requiring each package to be a standalone buildable unit.

#### Scenario: Configuration-based package
- **WHEN** a package consists primarily of configuration for an external tool
- **THEN** it MAY be built directly in root flake's perSystem
- **AND** it SHALL store configuration in `packages/<package-name>/config/`
- **AND** it SHALL use the appropriate builder tool as a library
- **AND** it SHALL NOT require its own flake.nix

### Requirement: Package Parameter Passing
The system SHALL pass necessary build parameters (pkgs, system, lib) to package builders through their documented API.

#### Scenario: Package built with builder tool
- **WHEN** a package is built using an external builder (e.g., nixvim)
- **THEN** it SHALL receive appropriate pkgs parameter for the target nixpkgs version
- **AND** it SHALL receive system parameter for architecture-specific builds
- **AND** additional parameters MAY be passed based on builder requirements
- **AND** the builder's makeXXXWithModule pattern SHALL be used when available

### Requirement: Per-Package Nixpkgs Version Selection
The system SHALL allow packages to use different nixpkgs versions when required by their builder tools to avoid version compatibility issues.

#### Scenario: Package requiring specific nixpkgs version
- **WHEN** a package builder (e.g., nixvim) requires a specific nixpkgs version
- **THEN** the package build SHALL import the required nixpkgs version
- **AND** this SHALL be isolated from the system's base nixpkgs version
- **AND** the package SHALL NOT produce version mismatch warnings
- **AND** appropriate nixpkgs channel (stable/unstable) SHALL be selected based on builder requirements

#### Example: Using unstable for nixvim
```nix
perSystem = { system, ... }:
  let
    pkgs-unstable = import inputs.unstable {
      inherit system;
      config.allowUnfree = true;
    };
  in
  {
    packages.mipvim = nixvim'.makeNixvimWithModule {
      pkgs = pkgs-unstable;  # Use unstable to match nixvim version
      # ...
    };
  };
```
