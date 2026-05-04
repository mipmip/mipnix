# Mipnix Integration

**Bean**: [mipbar-i8io](../../../.beans/mipbar-i8io--integrate-in-mipnix.md)
**Status**: proposed

## Why

Mipbar is ready to replace ashell as the primary status bar. It needs to be integrated into the mipnix NixOS configuration so it's built as a nix package, managed by home-manager, and started automatically with Hyprland.

## What Changes

- Move mipbar source from `~/cExperimental/mipbar/` to `~/mipnix/packages/mipbar/`
- Add AGS as a flake input in mipnix's `flake.nix`
- Build mipbar as a `perSystem.packages.mipbar` derivation
- Create a home-manager module that installs the package and sets up autostart
- Replace ashell with mipbar in Hyprland autostart
- Remove ashell config from home-manager
- Set up `hm-ricing-mode` symlink so `ags run .` works from the source directory for dev iteration

## Capabilities

### New Capabilities

- `mipnix-integration` — Mipbar built and deployed via mipnix, replacing ashell

### Modified Capabilities

None.

## Impact

- `~/mipnix/flake.nix` — add AGS flake input, add `packages.mipbar` to perSystem
- `~/mipnix/packages/mipbar/` — mipbar source (moved from cExperimental)
- `~/mipnix/modules/USERS/pim/programs/mipbar/default.nix` — new home-manager module
- `~/mipnix/modules/USERS/pim/programs/hyprland/default.nix` — remove ashell config
- `~/mipnix/modules/USERS/pim/programs/hyprland/hypr/autostart.conf` — swap ashell → mipbar
- `~/mipnix/modules/programs/desktop/de/hyprland.nix` — remove ashell from system packages

## Assumptions

- mipbar's existing `flake.nix` derivation works as a template for the mipnix build
- AGS flake input provides the `ags` bundler and all astal packages
- `hm-ricing-mode` can symlink the package source dir for live `ags run .` development
- Beans and openspec artifacts move with the source

## Non-goals

- Publishing mipbar as a standalone flake (staying embedded in mipnix)
- Running mipbar as a systemd service (stays as `exec-once` in hyprland)
- Removing ashell from the system entirely (just from autostart and home config)
