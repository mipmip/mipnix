# Tasks: add-noctalia-shell

## Phase 1: Flake Configuration
- [x] Add `noctalia` input to flake.nix with `inputs.nixpkgs.follows = "unstable"`
- [x] Verify flake lock updates correctly with `nix flake lock --update-input noctalia`

## Phase 2: Home Manager Module
- [x] Create `modules/users/pim/programs/noctalia/default.nix`
- [x] Import noctalia homeModules.default
- [x] Configure `programs.noctalia-shell.enable = true`
- [x] Configure `programs.noctalia-shell.systemd.enable = true`
- [x] Add basic settings configuration (can be customized later)
- [x] Register module in pim's Home Manager imports

## Phase 3: Hyprland Integration
- [x] Add Noctalia IPC keybindings to `binds.conf`:
  - Launcher toggle (SUPER+Space)
  - Session menu toggle (SUPER+SHIFT+Q)
  - Volume controls (handled elsewhere via wireplumber)
- [x] Remove ashell from autostart.conf (Noctalia systemd service handles startup)
- [x] Remove ashell from hyprland.nix packages

## Phase 4: Validation
- [x] Run `nixos-rebuild build` to verify configuration compiles
- [ ] Test Noctalia startup with `noctalia-shell` command
- [ ] Verify keybindings work correctly
- [ ] Confirm systemd service starts on login

## Notes
- Parallelizable: Phase 1 and scaffolding Phase 2 module structure
- Dependencies: Phase 3 requires Phase 2 complete; Phase 4 requires all phases
