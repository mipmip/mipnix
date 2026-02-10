# Tasks: add-noctalia-shell

## Phase 1: Flake Configuration
- [ ] Add `noctalia` input to flake.nix with `inputs.nixpkgs.follows = "nixpkgs"`
- [ ] Verify flake lock updates correctly with `nix flake lock --update-input noctalia`

## Phase 2: Home Manager Module
- [ ] Create `modules/users/pim/programs/noctalia/default.nix`
- [ ] Import noctalia homeModules.default
- [ ] Configure `programs.noctalia-shell.enable = true`
- [ ] Configure `programs.noctalia-shell.systemd.enable = true`
- [ ] Add basic settings configuration (can be customized later)
- [ ] Register module in pim's Home Manager imports

## Phase 3: Hyprland Integration
- [ ] Add Noctalia IPC keybindings to `binds.conf`:
  - Launcher toggle (e.g., SUPER+Space or similar)
  - Session menu toggle
  - Volume controls (if not handled elsewhere)
- [ ] Remove ashell from autostart.conf (Noctalia systemd service handles startup)
- [ ] Optionally remove ashell from hyprland.nix packages

## Phase 4: Validation
- [ ] Run `nixos-rebuild build` to verify configuration compiles
- [ ] Test Noctalia startup with `noctalia-shell` command
- [ ] Verify keybindings work correctly
- [ ] Confirm systemd service starts on login

## Notes
- Parallelizable: Phase 1 and scaffolding Phase 2 module structure
- Dependencies: Phase 3 requires Phase 2 complete; Phase 4 requires all phases
