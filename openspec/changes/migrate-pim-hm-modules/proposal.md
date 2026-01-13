# Change: Migrate pim's Home Manager modules to dendritic auto-import pattern

## Why
The current Home Manager module location at `home/pim/_hm-modules/` is inconsistent with the project's dendritic flake-parts module organization. The dendritic pattern auto-imports all files from `modules/`, eliminating the need for explicit file import management.

## What Changes
- Move all Home Manager module files from `home/pim/_hm-modules/` to `modules/users/pim/hm-modules/`
- by moving modules to `./modules` they are automatically imported with the import-tree flake.
- Remove the deprecated `_roles` import (roles are deprecated)
- Align with dendritic flake-parts conventions: all files in target directory are automatically discovered and imported
- This change affects **only user 'pim'** - user 'annemarie' is not included in this migration

## Impact
- Affected specs: `home-manager-config`
- Affected code:
  - `home/pim/_hm-modules/` → `modules/users/pim/hm-modules/` (directory move, flatten structure)
  - `home/pim/_hm-modules/default.nix` (delete - replaced by auto-import in home/pim/default.nix)
  - `home/pim/default.nix` (rewrite to use readDir auto-import pattern)
  - Individual module files (structure unchanged - remain as Home Manager modules)
  - `modules/nix/helpers.nix` (no changes - still imports from `../../home + "/${username}"`)
- Breaking changes: None - the module import chain remains functional, just more automatic
- Pattern shift: Manual import list → auto-discovery via readDir
- Users: Only affects 'pim' user configuration
