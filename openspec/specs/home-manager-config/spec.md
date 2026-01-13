# home-manager-config Specification

## Purpose
TBD - created by archiving change migrate-pim-hm-modules. Update Purpose after archive.
## Requirements
### Requirement: Centralized User Module Location
The system SHALL organize all user-specific Home Manager modules under `modules/users/<username>/` to maintain consistency with the dendritic flake-parts module structure.

#### Scenario: Pim user modules location
- **WHEN** Home Manager configuration is loaded for user 'pim'
- **THEN** all Home Manager modules SHALL be located in `modules/users/pim/` organized by category (programs/, fonts/, shared/, etc.)
- **AND** each module SHALL use the flake-parts structure: `flake.modules.homeManager.pim-<name> = { ... }`
- **AND** modules SHALL be discovered by import-tree at the flake root level

### Requirement: Manual Import-Based Activation
The system SHALL use a manual imports list to control which Home Manager modules are active for each user.

#### Scenario: Module activation via imports
- **WHEN** `modules/users/pim/home-manager.nix` is evaluated
- **THEN** it SHALL contain a manual imports list specifying which modules to activate
- **AND** only imported modules SHALL be active in the configuration
- **AND** modules NOT in the imports list SHALL NOT be active

#### Scenario: No self-referential enable options
- **WHEN** a Home Manager module is defined
- **THEN** it SHALL NOT define its own enable option (e.g., `desktopConf.alacritty.enable`)
- **AND** activation SHALL be controlled solely by presence in the imports list
- **AND** cross-module communication options (e.g., `shared.shellAliases`) MAY be defined

#### Scenario: Cross-module dependencies
- **WHEN** a module depends on another module
- **THEN** it SHALL directly import the dependency using `imports = [ inputs.self.modules.homeManager.pim-<dependency> ];`
- **AND** transitive imports through the root module SHOULD be avoided
- **AND** the dependency SHALL be active regardless of root imports list

### Requirement: Flake-Parts Module Structure
The system SHALL use flake-parts module classes for all Home Manager modules, enabling auto-discovery by import-tree.

#### Scenario: Module structure format
- **WHEN** a Home Manager module is created
- **THEN** it SHALL follow the format:
  ```nix
  {
  inputs,
  ...
  }:
  {
    flake.modules.homeManager.<username>-<module-name> = { config, pkgs, ... }: {
      # module configuration
    };
  }
  ```
- **AND** module parameters (config, lib, pkgs) SHALL be declared at the inner module level
- **AND** import-tree SHALL discover the module automatically

### Requirement: Home Entry Point Stability
The system SHALL maintain `home/<username>/default.nix` as the stable entry point for Home Manager configurations to preserve compatibility with the `makeHomeConf` helper function.

#### Scenario: Backward compatible import path
- **WHEN** `makeHomeConf` helper function constructs a home configuration
- **THEN** it SHALL import from `../../home + "/${username}"`
- **AND** that entry point SHALL remain unchanged during migration

