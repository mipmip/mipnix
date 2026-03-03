# Proposal: replace-ashell-with-waybar

## Summary

Replace ashell with waybar as the primary status bar for Hyprland, configured with desktop switcher (left), active application info (center), and system indicators including tray, time/date, power, and wifi (right).

## Why

- **Simpler setup**: Waybar configuration already exists in the codebase but is not being used
- **User preference**: User explicitly wants waybar with desktop switcher, active app info, systray, time/date, power, and wifi indicators
- **Proven solution**: Waybar is a mature, well-supported status bar for Wayland compositors
- **Active maintenance**: Waybar is actively maintained with good Hyprland integration

## Motivation

The current ashell configuration is being replaced to provide a more streamlined status bar experience. The existing waybar configuration is already present in the codebase and closely matches the desired layout. This change simplifies the Hyprland setup by using a well-established status bar solution.

## Scope

### In Scope
- Update Hyprland autostart to launch waybar instead of ashell
- Refine waybar configuration to match user requirements:
  - Desktop switcher (hyprland/workspaces) at top left
  - Active application info (hyprland/window) in middle
  - Systray at top right
  - Time and date at top right
  - Power indicator (battery) at top right
  - Wifi indicator (network) at top right

### Out of Scope
- Removal of ashell configuration files (kept for potential future use)
- Removal of ashell from Home Manager module (configuration preserved, just not started)
- Theme integration beyond existing waybar styling
- Additional waybar modules not requested by user
- Integration with notification systems (swaync remains unchanged)
- Launcher integration (elephant/walker remain unchanged)

## Approach

1. Update `modules/users/pim/programs/hyprland/hypr/autostart.conf` to replace `exec-once = ashell` with `exec-once = waybar`
2. Review and adjust waybar `config.jsonc` to ensure it matches user requirements:
   - Verify modules-left has `hyprland/workspaces` (desktop switcher)
   - Verify modules-center has `hyprland/window` (active app info)
   - Verify modules-right has `tray`, `clock` (time/date), `battery` (power), and `network` (wifi)
   - Remove or keep optional modules (cpu, backlight, pulseaudio) based on user preference
3. Keep ashell configuration in place for potential future use

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Waybar not installed in system | Verify waybar package is available and will be installed |
| Missing dependencies for indicators | Ensure required services (network-manager, upower) are available |
| Layout doesn't match expectations | Review configuration with user before implementing |

## Dependencies

- Requires: waybar package (likely already in nixpkgs)
- Optional services: NetworkManager (for wifi), upower (for battery)
