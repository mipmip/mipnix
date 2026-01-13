# Change: Migrate pim's Home Manager modules to dendritic flake-parts pattern

## Why
The current Home Manager module location at `home/pim/_hm-modules/` is inconsistent with the project's dendritic flake-parts module organization. The dendritic pattern uses flake-parts module classes (`flake.modules.homeManager.*`) which are auto-discovered by import-tree, providing centralized organization under `modules/users/pim/`.

## What Changes

### Phase 1: Migration to flake-parts structure
- Convert Home Manager modules from direct config to flake-parts module structure: `flake.modules.homeManager.pim-<name> = { ... }`
- Move modules from `home/pim/_hm-modules/<category>/` to `modules/users/pim/<category>/` (programs, fonts, gnome, shared)
- Add each migrated module to manual imports list in `modules/users/pim/home-manager.nix`
- Rename old module files to `.moved` to prevent duplicate imports while transitioning
- **Critical**: Stage all new files in git (nix flakes only see tracked files)
- Remove the deprecated `_roles` import (roles are deprecated)
- This change affects **only user 'pim'** - user 'annemarie' is not included in this migration

### Phase 2: Remove self-referential options/mkIf patterns
- Remove all self-referential enable options (e.g., `desktopConf.alacritty.enable`) from migrated modules
- Remove `lib.mkIf` wrappers that check self-referential enable options
- Preserve cross-module communication options (e.g., `shared.shellAliases`, `desktopConf.gnome.swapAltWin`)
- Preserve cross-module mkIf conditions (e.g., `lib.mkIf config.roles.secondbrain.enable`)
- Update fish and zsh to directly import shell-aliases module: `imports = [ inputs.self.modules.homeManager.pim-shared-shell-aliases ];`
- Remove `pim-shared-shell-aliases` from root imports in `home-manager.nix` (now imported directly by fish/zsh)
- Simplify module parameters where config/lib no longer needed

## Impact
- Affected specs: `home-manager-config`
- Affected code (Phase 1 - Migration):
  - `home/pim/_hm-modules/<category>/*.nix` → `modules/users/pim/<category>/*.nix` (39 modules migrated)
  - Each module wrapped in `flake.modules.homeManager.pim-<name> = { ... }` structure
  - `modules/users/pim/home-manager.nix` (manual imports list for all migrated modules)
  - Old files renamed to `*.moved` during transition
  - `home/pim/_hm-modules/` directory removed after completion
- Affected code (Phase 2 - Options/mkIf removal):
  - 19 modules updated to remove self-referential options and mkIf wrappers
  - Fish and zsh updated to directly import shell-aliases module
  - `modules/users/pim/home-manager.nix` updated to remove shell-aliases import (now transitive)
  - Modules with complex let bindings restructured (smug_n_skull, awscli-dir)
  - GNOME modules cleaned up while preserving swapAltWin configuration option
- Breaking changes: None - incremental approach allowed testing at each step
- Pattern shift: Direct Home Manager config → dendritic flake-parts with import-based activation
- Users: Only affects 'pim' user configuration
- Test machine: lego2-laptop (current machine)
