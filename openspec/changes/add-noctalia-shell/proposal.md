# Proposal: add-noctalia-shell

## Summary

Integrate Noctalia Shell as the primary Hyprland shell/bar replacement, replacing the current ashell setup. Noctalia is a modern shell providing a unified panel, launcher, and system controls.

## Motivation

- **Unified experience**: Noctalia provides an integrated panel, launcher, session menu, and system controls in one package
- **Active development**: Built on Quickshell with modern Material 3 theming
- **Feature-rich**: Includes volume/brightness controls, power management, notifications, and calendar integration

## Scope

### In Scope
- Add Noctalia flake input following nixpkgs unstable
- Create Home Manager module for Noctalia configuration
- Configure systemd service for automatic startup
- Add Hyprland keybindings for Noctalia IPC commands
- Remove ashell from the Hyprland module (replaced by Noctalia)

### Out of Scope
- NixOS service dependencies (user will configure separately)
- Theme integration with existing theme-wallpaper system (kept separate)
- Waybar removal (can be done as follow-up if desired)
- Calendar/evolution-data-server integration (optional enhancement)

## Approach

1. Add `noctalia` flake input pointing to `github:noctalia-dev/noctalia-shell`
2. Create new Home Manager module `pim-noctalia` at `modules/users/pim/programs/noctalia/`
3. Configure Noctalia with sensible defaults using the Home Manager module API
4. Update Hyprland binds.conf with Noctalia IPC keybindings (launcher, session menu, volume)
5. Remove ashell from autostart and system packages

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Noctalia requires nixpkgs unstable | Flake already has unstable input; Noctalia input follows nixpkgs |
| Missing system services | User confirmed they will handle service dependencies |
| Breaking existing workflow | Keep waybar available as fallback initially |

## Dependencies

- Requires: nixpkgs unstable (already present in flake)
- Optional services (user-managed): networkmanager, bluetooth, power-profiles-daemon/tuned, upower
