# Hyprland Workspaces Navigation

**Bean**: [mipbar-4c78](../../../.beans/mipbar-4c78--create-hyprland-workspaces-navigation.md)
**Status**: proposed

## Why

Mipbar needs workspace navigation to replace ashell's workspace module. Users need to see which workspaces have windows and quickly switch between them.

## What Changes

- Add `astal-hyprland` (hyprland) library to the flake
- Create a Workspaces widget showing occupied workspaces grouped by monitor
- Place it in the start section next to the walker launcher button
- Active workspace gets a pill-style highlight
- Clicking a workspace switches to it

## Capabilities

### New Capabilities

- `workspace-navigation` — Bar widget showing occupied hyprland workspaces with click-to-switch

### Modified Capabilities

None.

## Impact

- `flake.nix` — add `hyprland` to astalPackages
- `widget/Bar.tsx` — restructure start section to hold launcher + workspaces
- New widget file for workspaces
- `style.scss` — workspace button styles

## Assumptions

- Hyprland IPC socket is available (running under Hyprland)
- `astal-hyprland` library from AGS flake provides reactive workspace data
- Bar renders on all monitors; each bar shows all workspaces from all monitors

## Non-goals

- Drag-and-drop windows between workspaces
- Workspace creation/deletion from the bar
- Showing workspace names (just IDs)
- Per-monitor filtering (all bars show all workspaces)
