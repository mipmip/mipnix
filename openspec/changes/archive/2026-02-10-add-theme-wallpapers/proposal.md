# Change: Add theme-aware wallpapers

## Why

The wallpaper setup uses a single folder with no theme awareness. When switching between light and dark mode, GTK4 apps respond but the wallpaper stays unchanged, creating a visual disconnect.

## What Changes

- Reorganize wallpapers into `wallpapers-dark/` and `wallpapers-light/` directories
- Create a theme-switch script that updates wpaperd's wallpaper path
- Extend existing keybindings to call the theme-switch script

## Impact

- Affected code: `binds.conf`, `wpaperd/config.toml`, new theme-wallpaper script
- No spec changes (configuration/tooling only)

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
