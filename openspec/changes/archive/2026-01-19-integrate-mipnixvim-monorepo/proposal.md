# Change: Integrate mipnixvim into Monorepo

## Why
Currently, mipnixvim is maintained as a separate GitHub repository and referenced as an external flake input. This creates several challenges:

1. **Development friction**: Changes to mipnixvim require switching repositories, separate commits, and waiting for GitHub to sync before testing in mipnix
2. **Version coordination**: Keeping mipnixvim synchronized with mipnix configuration changes requires manual flake.lock updates
3. **Build complexity**: The external dependency adds an extra layer of flake evaluation and fetching
4. **Repository fragmentation**: Personal NixOS configuration is split across multiple repositories, making it harder to understand the complete system

Integrating mipnixvim directly into the monorepo (renamed to mipvim) will streamline development, enable atomic changes across both neovim configuration and system configuration, and simplify the overall build process.

## What Changes
- Move the mipvim configuration from the external mipnixvim repository into `packages/mipvim/config/` within the mipnix monorepo
- Add nixvim and pre-commit-hooks as direct inputs to the root flake.nix
- Build mipvim package directly in root flake's perSystem using nixvim's makeNixvimWithModule
- Configure mipvim to use unstable nixpkgs channel to match nixvim version requirements
- Update all references to `inputs.mipnixvim` to use `inputs.self.packages.${system}.mipvim`
- Remove the external mipvim flake input from flake.nix
- Remove the standalone flake.nix from packages/mipvim (integrated directly into root flake)
- Update flake.lock to remove the mipvim dependency and add nixvim/pre-commit-hooks
- Remove mipvim from extraSpecialArgs in helpers.nix
- Update project documentation to reflect the new monorepo structure

## Impact
- **Affected specs**: flake-structure (new), package-management (new)
- **Affected code**: 
  - `flake.nix` (inputs, perSystem package definition)
  - `flake.lock` (dependency updates: removed mipvim, added nixvim/pre-commit-hooks)
  - `modules/users/pim/programs/neovim/default.nix` (package reference)
  - `modules/nix/helpers.nix` (removed mipvim from extraSpecialArgs)
  - `packages/mipvim/config/` (configuration files migrated from external repo)
  - `packages/mipvim/config/plugins/editor/treesitter.nix` (fixed deprecation warnings)
  - `packages/mipvim/config/plugins/editor/neo-tree.nix` (migrated to settings structure)
  - `openspec/project.md` (documentation)
- **External dependencies**: 
  - Added: nixvim (from nix-community)
  - Added: pre-commit-hooks
  - Removed: mipvim local flake reference
- **Breaking changes**: None for end users; internal flake structure changes only
- **Package integration**: mipvim built directly in root flake using nixvim, not as separate flake
