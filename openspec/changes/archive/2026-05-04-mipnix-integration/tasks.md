# Tasks: Mipnix Integration

## 1. Add AGS Flake Input

- [x] 1.1 Add AGS flake input to `~/mipnix/flake.nix` with nixpkgs follows
- [x] 1.2 Verify the input resolves (`nix flake lock --update-input ags`)

## 2. Move Source

- [x] 2.1 Copy mipbar source from `~/cExperimental/mipbar/` to `~/mipnix/packages/mipbar/`
- [x] 2.2 Verify all files are present (widget/, app.ts, style.scss, package.json, tsconfig.json)
- [x] 2.3 Remove the mipbar flake.nix and flake.lock from the copied source (build moves to mipnix flake)

## 3. Build Package in mipnix

- [x] 3.1 Add `packages.mipbar` to `perSystem` in `~/mipnix/flake.nix` — port the derivation from mipbar's flake.nix
- [x] 3.2 Define astalPackages list (io, astal4, hyprland, network, battery, tray)
- [x] 3.3 Define extraPackages (astalPackages + libadwaita, libsoup_3)
- [x] 3.4 Set pname to `mipbar`, entry to `app.ts`, source to `./packages/mipbar`
- [x] 3.5 Verify build: `nix build .#mipbar`

## 4. Create Home-Manager Module

- [x] 4.1 Create `~/mipnix/modules/USERS/pim/programs/mipbar/default.nix`
- [x] 4.2 Add mipbar package to `home.packages`
- [x] 4.3 Configure `hm-ricing-mode` symlink for dev workflow

## 5. Swap Ashell for Mipbar

- [x] 5.1 Replace `exec-once = ashell` with `exec-once = mipbar` in `autostart.conf`
- [x] 5.2 Remove ashell config from `home.file` in hyprland module
- [x] 5.3 Remove ashell from system packages in `hyprland.nix` (optional — can keep installed)

## 6. Add to Desktop Role

- [x] 6.1 Add `pim-mipbar` to the imports in `home-pim-desktop.nix`

## 7. Verify

- [x] 7.1 Run `nixos-rebuild switch` and confirm mipbar starts with Hyprland
- [x] 7.2 Verify `ags run .` works from the source directory for dev iteration
- [x] 7.3 Verify ashell no longer starts
