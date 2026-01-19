# Change: Integrate mipnixvim into Monorepo

## Why
Currently, mipnixvim is maintained as a separate GitHub repository and referenced as an external flake input. This creates several challenges:

1. **Development friction**: Changes to mipnixvim require switching repositories, separate commits, and waiting for GitHub to sync before testing in mipnix
2. **Version coordination**: Keeping mipnixvim synchronized with mipnix configuration changes requires manual flake.lock updates
3. **Build complexity**: The external dependency adds an extra layer of flake evaluation and fetching
4. **Repository fragmentation**: Personal NixOS configuration is split across multiple repositories, making it harder to understand the complete system

Integrating mipnixvim directly into the monorepo (renamed to mipvim) will streamline development, enable atomic changes across both neovim configuration and system configuration, and simplify the overall build process.

## What Changes
- Move the entire mipnixvim repository code into `packages/mipvim/` within the mipnix monorepo (renamed from mipnixvim to mipvim)
- Update flake.nix to expose mipvim as a local package output instead of an external input
- Update all references to `inputs.mipnixvim` to use the local mipvim package
- Remove the external mipnixvim flake input from flake.nix
- Update flake.lock to remove the mipnixvim dependency
- Update smug/skull configurations that reference the external mipnixvim repository
- Preserve the package's ability to be built independently (keep its flake.nix)
- Update project documentation to reflect the new monorepo structure and mipvim naming

## Impact
- **Affected specs**: flake-structure (new), package-management (new)
- **Affected code**: 
  - `flake.nix` (inputs and package outputs)
  - `flake.lock` (dependency removal)
  - `modules/users/pim/programs/neovim/default.nix` (package reference)
  - `modules/users/pim/programs/smug_n_skull/` (working copy configuration)
  - `modules/nix/helpers.nix` (special arguments)
  - `openspec/project.md` (documentation)
- **External dependencies**: The GitHub repository github:mipmip/mipnixvim will remain but become read-only/archived (decision deferred to deployment)
- **Breaking changes**: None for end users; internal flake structure changes only
- **Package renaming**: mipnixvim → mipvim (shorter, cleaner name for the integrated package)
