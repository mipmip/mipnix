# Change: Migrate pim's Home Manager modules to dendritic flake-parts pattern

## Why
The current Home Manager module location at `home/pim/_hm-modules/` is inconsistent with the project's dendritic flake-parts module organization. The dendritic pattern uses flake-parts module classes (`flake.modules.homeManager.*`) which are auto-discovered by import-tree, providing centralized organization under `modules/users/pim/`.

## What Changes
- Convert Home Manager modules from direct config to flake-parts module structure: `flake.modules.homeManager.pim-<name> = { ... }`
- Move modules from `home/pim/_hm-modules/<category>/` to `modules/users/pim/<category>/` (programs, fonts, gnome, shared)
- Add each migrated module to imports list in `modules/users/pim/home-manager.nix`
- Rename old module files to `.moved` to prevent duplicate imports while transitioning
- **Critical**: Stage all new files in git (nix flakes only see tracked files)
- Remove the deprecated `_roles` import (roles are deprecated)
- This change affects **only user 'pim'** - user 'annemarie' is not included in this migration

## Impact
- Affected specs: `home-manager-config`
- Affected code:
  - `home/pim/_hm-modules/<category>/*.nix` → `modules/users/pim/<category>/*.nix` (file-by-file migration)
  - Each module wrapped in `flake.modules.homeManager.pim-<name> = { ... }` structure
  - `modules/users/pim/home-manager.nix` (add imports for each migrated module)
  - Old files renamed to `*.moved` during transition
  - `home/pim/default.nix` remains unchanged (still imports from `_hm-modules` during transition)
  - After all modules migrated, can remove `home/pim/_hm-modules/` entirely
- Breaking changes: None - incremental migration allows testing each module
- Pattern shift: Direct Home Manager config → flake-parts module classes
- Users: Only affects 'pim' user configuration
- Test machine: lego2-laptop (current machine)
