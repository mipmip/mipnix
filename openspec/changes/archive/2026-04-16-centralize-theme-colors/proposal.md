## Why

Theme colors (active/inactive background) are duplicated as hardcoded hex values in both the tmux module and neovim config. Changing a color requires updating two separate files, risking drift. Centralizing them in a shared colors definition gives a single source of truth and makes the dimming behavior consistent across tmux panes and neovim windows.

## What Changes

- Add a shared colors definition file that both tmux and neovim consume
- Create a home-manager module under `modules/themes/` (auto-discovered by import-tree) that exposes `mip.theme.colors` options
- Pass colors into the nixvim module via `extraSpecialArgs` in `flake.nix`
- Update tmux module to read from `config.mip.theme.colors` instead of hardcoded values
- Add `NormalNC` highlight to neovim using the shared inactive background color
- Document the shared color system

## Capabilities

### New Capabilities
- `shared-theme-colors`: Centralized color definitions consumed by both tmux and neovim, exposed as home-manager options and passed to nixvim via extraSpecialArgs

### Modified Capabilities

## Impact

- `modules/themes/` — new home-manager module defining color options and defaults
- `flake.nix` — pass colors into nixvim `extraSpecialArgs`
- `modules/user-pim/programs/tmux/default.nix` — replace hardcoded hex values with `config.mip.theme.colors`
- `packages/mipvim/config/` — add `NormalNC` highlight using colors from extraSpecialArgs
