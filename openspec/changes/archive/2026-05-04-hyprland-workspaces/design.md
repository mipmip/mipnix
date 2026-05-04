# Design: Hyprland Workspaces Navigation

## Context

The bar currently has a walker launcher button in the start section and a clock in the end section. We need to add workspace navigation next to the launcher. The `astal-hyprland` library provides reactive GObject bindings for Hyprland's IPC.

## Goals / Non-Goals

**Goals**:
- Show occupied workspaces from all monitors, grouped by monitor
- Pill-style active indicator
- Click to switch workspace
- Reactive updates as workspaces/clients change

**Non-Goals**:
- Per-monitor filtering
- Showing empty workspaces
- Workspace management (create/delete/rename)

## Decisions

### Use astal-hyprland library

Import `AstalHyprland` via `gi://AstalHyprland`. Use `Hyprland.get_default()` for the singleton instance.

**Why**: This is the AGS-blessed approach. The library handles IPC, provides reactive GObject properties, and emits signals on workspace/client changes. No need to manually manage sockets.

### Create a separate Workspaces widget file

Create `widget/Workspaces.tsx` as a dedicated component.

**Why**: Keeps Bar.tsx clean. The workspace logic (filtering, grouping, reactivity) is complex enough to warrant its own file.

### Restructure Bar start section as a horizontal box

The start section changes from a single button to a `<box>` containing `[AppLauncher] [Workspaces]`.

**Why**: The centerbox start slot accepts a single widget. Wrapping in a box lets us compose multiple widgets.

### Filter by client count, react to signals

Use `hyprland.workspaces` filtered by `workspace.clients.length > 0`. Listen to `workspace_added`, `workspace_removed`, and client change signals to re-render.

**Why**: Only showing occupied workspaces means we need to react to client add/remove events, not just workspace events.

### Group workspaces by monitor name

Group workspace buttons by `workspace.monitor.name` and render each group in its own `<box>` with a visual separator (margin/gap).

**Why**: Makes it clear which workspaces belong to which monitor without needing labels.

### Pill-style active indicator via CSS class toggle

Add a CSS class (e.g., `focused`) to the active workspace button. Style it with a distinct background and border-radius to create the pill look.

**Why**: Simple, performant, follows the existing pattern in the codebase. Bind the class reactively to `hyprland.focused_workspace`.

## Risks / Trade-offs

[Risk] Hyprland signals may not fire for all client add/remove events → Mitigation: Test thoroughly; fall back to polling if needed.

[Risk] Workspace IDs may include special workspaces (negative IDs) → Mitigation: Filter to only positive workspace IDs.

## Open Questions

None.
