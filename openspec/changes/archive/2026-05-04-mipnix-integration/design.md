# Design: Mipnix Integration

## Context

Mipbar is developed at `~/cExperimental/mipbar/` with its own `flake.nix` that builds via AGS. It needs to move into `~/mipnix/` following the nixvim/mipvim pattern: source in `packages/`, built in `perSystem`, installed via home-manager.

## Goals / Non-Goals

**Goals**:
- Build mipbar as a nix package inside mipnix
- Install via home-manager, autostart with Hyprland
- Keep `ags run .` dev workflow via hm-ricing-mode
- Move beans and openspec with the source

**Non-Goals**:
- Making mipbar a standalone publishable flake
- Systemd service management
- Fully removing ashell from the system (just from autostart)

## Decisions

### Follow the mipvim pattern

Build mipbar in `perSystem.packages` in mipnix's `flake.nix`, source at `packages/mipbar/`.

**Why**: Consistent with how mipvim is built from nixvim. The package is self-contained in `packages/`, the flake builds it, home-manager installs it.

### Add AGS as a flake input to mipnix

Add the AGS flake as an input in mipnix's `flake.nix` with nixpkgs following.

**Why**: AGS provides the bundler CLI and all astal library packages. The existing mipbar flake.nix already uses this pattern — we're just moving it up to the mipnix level.

### Port the derivation from mipbar's flake.nix

Copy the `stdenv.mkDerivation` and `astalPackages` definitions from mipbar's current `flake.nix` into mipnix's `perSystem`.

**Why**: The derivation already works. No need to redesign — just move it into the mipnix build.

### Create a home-manager module at `modules/USERS/pim/programs/mipbar/`

The module:
- Adds `inputs.self.packages.${system}.mipbar` to `home.packages`
- Sets up `hm-ricing-mode` symlink for the source directory

**Why**: Follows the exact pattern of other pim programs (neovim, dirty-repo-scanner).

### Use hm-ricing-mode for dev workflow

Configure `programs.hm-ricing-mode.apps.mipbar` to symlink the source directory so `ags run .` works from the nix store source.

**Why**: This is how hyprland config is already managed — hm-ricing-mode creates symlinks from the store path to a writable location, enabling live editing.

### Swap autostart in hyprland config

Replace `exec-once = ashell` with `exec-once = mipbar` (the binary name from the derivation) in `autostart.conf`. Remove ashell config from `home.file`.

**Why**: Direct replacement. Both are status bars for the same position.

### Rename the binary to `mipbar`

Change `pname` in the derivation from `my-shell` to `mipbar`.

**Why**: Clear naming that matches the project.

## Risks / Trade-offs

[Risk] AGS flake input may conflict with existing nixpkgs versions → Mitigation: Use `inputs.nixpkgs.follows` on the AGS input.

[Risk] hm-ricing-mode symlinks may not work for `ags run .` if AGS expects files in specific locations → Mitigation: Test the dev workflow before removing ashell from autostart.

[Risk] Moving the source may break git history → Mitigation: Use `git mv` or copy + commit to preserve context. The old repo at cExperimental can be archived.

## Open Questions

None.
