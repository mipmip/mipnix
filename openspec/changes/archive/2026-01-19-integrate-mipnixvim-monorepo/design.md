# Design: Integrate mipnixvim into Monorepo

## Overview
This change moves mipvim from an external GitHub-based flake input to a directly integrated package within the mipnix monorepo. The configuration is built using nixvim directly in the root flake's perSystem, eliminating the need for a separate flake.nix within the package.

## Architectural Decisions

### 1. Package Location and Structure
**Decision**: Place mipvim configuration in `packages/mipvim/config/` without a standalone flake.nix

**Rationale**:
- Configuration files only, no separate flake needed
- Built directly by root flake using nixvim's makeNixvimWithModule
- Separates package configuration from system configuration modules
- Simpler maintenance - one flake.nix instead of two
- Uses nixvim as a library rather than as an external package

**Alternatives considered**:
- Keep standalone flake.nix - Rejected: Adds complexity, duplicate input management
- Place in modules/ - Rejected: Not a NixOS/HM module, it's a package configuration
- Use as git submodule - Rejected: Still requires external repo, adds complexity

### 2. Flake Integration Strategy
**Decision**: Build mipvim directly in root flake's perSystem using nixvim as a library

**Rationale**:
- Aligns with existing flake-parts architecture
- Provides clean `packages.${system}.mipvim` output
- Uses import-tree to load configuration from `packages/mipvim/config/`
- Nixvim becomes a direct dependency, eliminating flake indirection
- Simpler to maintain - single source of truth for inputs

**Implementation approach**:
```nix
perSystem = { system, pkgs, ... }:
  let
    pkgs-unstable = import inputs.unstable {
      inherit system;
      config.allowUnfree = true;
    };
    
    nixvimLib = inputs.nixvim.lib.${system};
    nixvim' = inputs.nixvim.legacyPackages.${system};
    nixvimModule = {
      pkgs = pkgs-unstable;
      module = {
        imports = [
          (inputs.import-tree ./packages/mipvim/config)
        ];
      };
      extraSpecialArgs = { };
    };
  in
  {
    packages.mipvim = nixvim'.makeNixvimWithModule nixvimModule;
    checks.mipvim = nixvimLib.check.mkTestDerivationFromNixvimModule nixvimModule;
  };
```

**Key points**:
- Uses unstable nixpkgs for mipvim to match nixvim version requirements
- Leverages import-tree for modular configuration loading
- Provides both package and check outputs

**Alternatives considered**:
- Keep separate flake.nix - Rejected: Duplicates input management, adds complexity
- Import as external input - Rejected: The problem we're solving
- Git submodule - Rejected: Adds complexity without benefits

### 3. Reference Update Strategy
**Decision**: Replace `inputs.mipvim` (from local flake) with `inputs.self.packages.${system}.mipvim`

**Rationale**:
- Standard pattern for referencing packages from same flake
- Leverages existing flake-parts special arguments mechanism
- Clear and explicit package reference

**Impact points**:
- `modules/users/pim/programs/neovim/default.nix`: Updated to use `inputs.self.packages."${system}".mipvim`
- `modules/nix/helpers.nix`: Removed mipvim from extraSpecialArgs
- `flake.nix`: Removed local path input, added nixvim/pre-commit-hooks inputs, defined package in perSystem

### 4. Nixpkgs Version Management
**Decision**: Use unstable nixpkgs specifically for mipvim build

**Rationale**:
- Nixvim from unstable requires matching nixpkgs version
- Eliminates version mismatch warnings between nixvim and package dependencies
- Root system uses stable (25.11), mipvim uses unstable - isolated appropriately
- Follows existing pattern in channels.nix for unstable overlay

**Implementation**:
```nix
let
  pkgs-unstable = import inputs.unstable {
    inherit system;
    config.allowUnfree = true;
  };
in
{
  packages.mipvim = nixvim'.makeNixvimWithModule {
    pkgs = pkgs-unstable;
    # ...
  };
}
```

**Benefits**:
- No version mismatch warnings
- Latest neovim features from unstable
- Isolated from system stability requirements

### 5. Configuration Migration and Updates
**Decision**: Migrate configuration files and fix nixvim API deprecations

**Rationale**:
- Newer nixvim version requires updated configuration syntax
- Move to `settings.*` structure for most plugin options
- Fix deprecation warnings proactively

**Changes made**:
- `treesitter.nix`: Changed `folding = false` to `folding.enable = false`
- `neo-tree.nix`: Moved all top-level options to `settings.*` structure
- `neo-tree.nix`: Changed camelCase to snake_case for upstream consistency

**Remaining deprecations**:
- treesitter-textobjects options still using old API (non-breaking warnings)
- Can be updated incrementally as needed

## Migration Path

### Phase 1: Add Nixvim Dependencies
1. Add nixvim and pre-commit-hooks inputs to root flake.nix
2. Remove local mipvim flake input
3. Update flake.lock

### Phase 2: Create Package Configuration
1. Keep existing `packages/mipvim/config/` directory structure
2. Remove standalone flake.nix, flake.lock, and related files from packages/mipvim/
3. Build package directly in root flake's perSystem

### Phase 3: Fix Configuration Issues
1. Update treesitter folding syntax
2. Move neo-tree options to settings structure
3. Test build and resolve any remaining issues

### Phase 4: Update References
1. Update neovim module to reference `inputs.self.packages`
2. Remove mipvim from helpers.nix extraSpecialArgs
3. Verify all references updated

### Phase 5: Validation
1. Test build: `nix build .#mipvim`
2. Verify no version mismatch warnings
3. Test neovim launches and functions correctly

## Risks and Mitigations

### Risk: Build breakage
**Mitigation**: Test build after each phase, verify package output exists

### Risk: Version mismatch warnings
**Mitigation**: Use unstable nixpkgs for mipvim build to match nixvim version

### Risk: Configuration incompatibility
**Mitigation**: Update configuration to new nixvim API, fix deprecations proactively

### Risk: Module reference errors
**Mitigation**: Update all references atomically, test with `nix flake check`

## Future Considerations

### Direct nixvim integration pattern
This integration establishes a pattern for using nixvim as a library:
- Configuration in `packages/<name>/config/`
- Built directly in root flake perSystem
- No standalone flake needed
- Can be applied to other nixvim-based configurations

### Potential configuration improvements
- Update remaining treesitter-textobjects to new API
- Migrate more plugins to settings.* structure as nixvim evolves
- Consider splitting large plugin configurations into smaller files
