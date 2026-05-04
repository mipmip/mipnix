## Why

Workspace buttons currently show only their numeric ID, giving no indication of what's running in each workspace. Users have to click through workspaces to find the app they're looking for. Showing application icons inline makes workspace navigation faster and more intuitive.

Related task: [mipbar-mmke](.beans/mipbar-mmke--show-app-icons-per-workspace.md)

## What Changes

- Workspace buttons display one desktop icon per window (client) running in that workspace, alongside the workspace ID
- Hovering an individual app icon shows that window's title as a tooltip
- Workspace icon lists update reactively when windows open, close, or move between workspaces
- A fallback icon is shown for applications whose class doesn't resolve to a theme icon

## Capabilities

### New Capabilities

- `workspace-app-icons`: Display one icon per window within each workspace button using GTK icon theme lookup from Hyprland client class names, with per-icon tooltip showing individual window titles on hover

### Modified Capabilities

- `workspace-navigation`: Add reactivity to client-level changes (open/close/move) so workspace buttons update when their contents change, not just when workspaces are added or removed

## Impact

- `widget/Workspaces.tsx`: Major changes — add icon rendering, tooltip, and client-level signal handling
- `style.scss`: New styles for icons within workspace buttons (sizing, spacing, overflow)
- Icon theme dependency: relies on the active GTK icon theme having entries for common app classes
