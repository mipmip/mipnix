# Proposal: add-nwg-panel-quick-settings

## Summary

Add nwg-panel as a dedicated quick settings control center for Hyprland, providing easy access to audio, brightness, network, bluetooth, and power settings via a popup panel triggered by keybinding.

## Why

Currently, waybar provides an excellent status bar with indicators, but lacks a quick settings/control center panel similar to GNOME or ashell. Users need a convenient way to adjust system settings without opening full applications.

## Motivation

- **Quick access to settings**: Adjust volume, brightness, connect to wifi/bluetooth without opening full control panels
- **Modular design**: Keep waybar for status bar, add nwg-panel specifically for quick settings popup
- **Native Wayland**: nwg-panel is built for wlroots compositors (Sway, Hyprland) with proper Wayland support
- **Lightweight**: GTK3-based, minimal resource usage

## Scope

### In Scope
- Add nwg-panel package to Hyprland environment
- Create Home Manager configuration for nwg-panel
- Configure nwg-panel with controls module for quick settings:
  - Volume/audio controls
  - Brightness controls
  - Network (wifi) management
  - Bluetooth management
  - Power/battery settings
- Add Hyprland keybinding to toggle nwg-panel quick settings popup
- Add clickable icon to waybar (top right) that triggers nwg-panel popup
- Configure nwg-panel to run as on-demand popup (not persistent bar)

### Out of Scope
- Replacing waybar (waybar remains as the status bar)
- Full panel configuration (focus on quick settings controls module)
- Notification integration (swaync continues to handle notifications)
- Launcher integration (walker/elephant continue to handle app launching)
- Advanced theming (use sensible defaults)

## Approach

1. Add nwg-panel to system packages in `modules/programs/desktop/de/hyprland.nix`
2. Create new Home Manager module `pim-nwg-panel` at `modules/users/pim/programs/nwg-panel/`
3. Configure nwg-panel with minimal configuration focused on controls module:
   - Enable controls module for quick settings
   - Configure audio, brightness, network, bluetooth widgets
   - Set panel to popup mode (not always visible)
   - Position appropriately (top-right suggested)
4. Add Hyprland keybinding (e.g., `SUPER + A` or `SUPER + SHIFT + S`) to toggle nwg-panel
5. Add custom module to waybar configuration:
   - Add clickable icon/button in modules-right (before clock)
   - Icon triggers nwg-panel when clicked (e.g., "󰒓" or "")
   - Position in waybar: `modules-right: ["tray", "network", "battery", "custom/quicksettings", "clock"]`
6. Test that nwg-panel and waybar coexist without conflicts

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Conflicts with waybar | Configure nwg-panel as popup-only, not persistent bar |
| Missing system dependencies | Ensure NetworkManager, bluez, pulseaudio/pipewire are available |
| Keybinding conflicts | Choose unused keybinding, document in config |
| GTK theming issues | Use default theme initially, can customize later |

## Dependencies

- Requires: nwg-panel package (available in nixpkgs)
- System services: NetworkManager, bluez, pipewire/pulseaudio, brightnessctl/light
- Runtime: GTK3, layer-shell support (already present in Hyprland)
