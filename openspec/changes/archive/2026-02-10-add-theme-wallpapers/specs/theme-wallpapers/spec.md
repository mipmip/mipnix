# Capability: theme-wallpapers

Theme-aware wallpaper management for Hyprland desktop.

## ADDED Requirements

### Requirement: Theme wallpaper directories

The system MUST organize wallpapers into separate directories based on theme:
- `resources/wallpapers-dark/` for dark mode wallpapers
- `resources/wallpapers-light/` for light mode wallpapers

#### Scenario: Dark wallpaper directory exists

**Given** the mipnix repository
**When** checking the resources directory
**Then** `resources/wallpapers-dark/` directory exists and contains at least one image file

#### Scenario: Light wallpaper directory exists

**Given** the mipnix repository
**When** checking the resources directory
**Then** `resources/wallpapers-light/` directory exists and contains at least one image file

---

### Requirement: Theme wallpaper switch script

The system MUST provide a script that switches wpaperd to use the appropriate wallpaper directory based on the requested theme.

#### Scenario: Switch to dark wallpapers

**Given** wpaperd is running
**When** executing `theme-wallpaper dark`
**Then** wpaperd reloads with wallpapers from `resources/wallpapers-dark/`

#### Scenario: Switch to light wallpapers

**Given** wpaperd is running
**When** executing `theme-wallpaper light`
**Then** wpaperd reloads with wallpapers from `resources/wallpapers-light/`

---

### Requirement: Keybinding integration

The existing theme toggle keybindings MUST trigger wallpaper switching in addition to GTK theme changes.

#### Scenario: Dark mode keybinding switches wallpaper

**Given** Hyprland is running with wpaperd
**When** user presses `SUPER+D`
**Then** GTK4 theme switches to prefer-dark AND wallpaper switches to dark mode

#### Scenario: Light mode keybinding switches wallpaper

**Given** Hyprland is running with wpaperd
**When** user presses `SUPER+SHIFT+D`
**Then** GTK4 theme switches to prefer-light AND wallpaper switches to light mode

## MODIFIED Requirements

### Requirement: Default wallpaper path

The wpaperd configuration MUST use a theme-specific wallpaper directory as default instead of the generic `resources/wallpapers/` path.

#### Scenario: wpaperd starts with themed wallpapers

**Given** wpaperd configuration is loaded
**When** wpaperd starts
**Then** wallpapers are sourced from `resources/wallpapers-dark/` (default dark theme)
