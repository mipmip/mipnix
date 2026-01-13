# Home Manager Configuration - Spec Delta

## ADDED Requirements

### Requirement: Centralized User Module Location
The system SHALL organize all user-specific Home Manager modules under `modules/users/<username>/hm-modules/` to maintain consistency with the dendritic flake-parts module structure.

#### Scenario: Pim user modules location
- **WHEN** Home Manager configuration is loaded for user 'pim'
- **THEN** all Home Manager modules SHALL be imported from `modules/users/pim/hm-modules/`
- **AND** the entry point SHALL remain at `home/pim/default.nix` for backward compatibility

### Requirement: Dendritic Auto-Import Pattern
The system SHALL use auto-discovery via `readDir` to import Home Manager modules, eliminating manual import management and following dendritic principles.

#### Scenario: Automatic module discovery
- **WHEN** `home/pim/default.nix` is evaluated
- **THEN** it SHALL use `builtins.readDir` to discover all `.nix` files in `modules/users/pim/hm-modules/`
- **AND** it SHALL automatically import each discovered module
- **AND** it SHALL NOT use a `default.nix` entry point in the hm-modules directory

#### Scenario: No manual import lists
- **WHEN** a new Home Manager module is added to `modules/users/pim/hm-modules/`
- **THEN** it SHALL be automatically discovered and imported without modifying any import statements
- **AND** the module SHALL be loaded as part of the Home Manager configuration

### Requirement: Home Entry Point Stability
The system SHALL maintain `home/<username>/default.nix` as the stable entry point for Home Manager configurations to preserve compatibility with the `makeHomeConf` helper function.

#### Scenario: Backward compatible import path
- **WHEN** `makeHomeConf` helper function constructs a home configuration
- **THEN** it SHALL import from `../../home + "/${username}"`
- **AND** that entry point SHALL delegate to the actual module location

## MODIFIED Requirements

None - this is the initial specification for home-manager-config capability.

## REMOVED Requirements

### Requirement: Co-located Home Manager Modules
**Reason**: The previous pattern of placing Home Manager modules directly under `home/<username>/_hm-modules/` created organizational inconsistency with the dendritic flake-parts module structure.

**Migration**: Move all module files from `home/pim/_hm-modules/` to `modules/users/pim/hm-modules/` and implement auto-import pattern.

### Requirement: Manual Default.nix Entry Point
**Reason**: Using `default.nix` as an explicit entry point that manually imports subdirectories is an anti-pattern in the dendritic system. Auto-import via `readDir` is the preferred approach.

**Migration**: Delete `home/pim/_hm-modules/default.nix` and implement auto-discovery in `home/pim/default.nix` using `builtins.readDir` to import all modules from the new location.
