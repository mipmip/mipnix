# Proposal: add-theme-wallpapers

## Summary

Add support for separate light and dark mode wallpapers in Hyprland, integrated with the existing theme toggle keybindings (`SUPER+D` for dark, `SUPER+SHIFT+D` for light).

## Motivation

Currently, the wallpaper setup uses a single folder (`resources/wallpapers/`) via wpaperd with no awareness of the system theme. When switching between light and dark mode using the existing keybindings, only GTK4 applications respond. The desktop wallpaper remains unchanged, creating a visual disconnect.

## Proposed Solution

1. **Reorganize wallpapers** into two directories:
   - `resources/wallpapers-dark/` - wallpapers suited for dark mode
   - `resources/wallpapers-light/` - wallpapers suited for light mode

2. **Create a theme-switch script** that:
   - Updates wpaperd's wallpaper path based on the requested theme
   - Triggers an immediate wallpaper reload

3. **Extend existing keybindings** to call the theme-switch script alongside the current gsettings commands

## Scope

- Minimal changes to existing configuration
- Uses wpaperd's existing reload capability
- Integrates with established keybinding pattern
- No new packages required

## Affected Files

- `modules/users/pim/programs/hyprland/hypr/binds.conf` - extend keybindings
- `modules/users/pim/programs/hyprland/wpaperd/config.toml` - update default path
- New: `scripts/theme-wallpaper` - theme switching script
- New: `resources/wallpapers-dark/` - dark mode wallpapers directory
- New: `resources/wallpapers-light/` - light mode wallpapers directory
