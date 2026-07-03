## Context

mipbar is an Astal/AGS (GTK4 + TypeScript/JSX) bar. Its `end` cluster holds small
status widgets (Camera, Screenshare, SshKey, SystemMonitor, QuickSettings). Two
existing patterns are directly reusable:

- `Workspaces.tsx` reads live Hyprland state via `AstalHyprland`
  (`get_workspaces()`, `Workspace.get_clients()`), maps clients to icons with
  `lookupIcon(wmClass)` from `utils.ts`, and refreshes on Hyprland signals
  (`client-added`/`-removed`/`-moved`, `notify::workspaces`).
- `SshKey.tsx` / `QuickSettings.tsx` use a `menubutton` + `<popover>` with
  `StatusRow` / `ActionSmall` styling for click-through actions.

Minimize is implemented by the `hypr-longpress` menu: its "Minimize" action runs
`hyprctl dispatch movetoworkspacesilent special:minimized,<addr>`. So minimized
windows live in the `special:minimized` special workspace (a negative-id
workspace, observed as id `-98`). Nothing currently surfaces or restores them —
`Workspaces.tsx` even filters `w.id >= 0`, so the special workspace is invisible
there by design.

## Goals / Non-Goals

**Goals:**
- Reveal which windows are minimized, and restore them, from the bar.
- Hide the indicator when nothing is minimized (no clutter).
- Reuse the existing AstalHyprland + popover patterns; live, event-driven updates.

**Non-Goals:**
- Changing the minimize action or the `special:minimized` mechanism.
- Restoring to the *original* workspace (origin is not tracked — see Decisions).
- A general window switcher / alt-tab replacement.

## Decisions

### Read `special:minimized` via AstalHyprland

Find the workspace whose name is `special:minimized` in `get_workspaces()` and
read its `get_clients()`. Match by **name**, not the numeric id (`-98` is not
guaranteed stable). Each client gives `class`/`title`/`address`; `lookupIcon` maps
the class to an icon, exactly as `Workspaces.tsx` does.

### Hide-when-empty

Bind the widget's `visible` to "minimized count > 0" (like `Camera`, which hides
when no camera is in use). The common state (nothing minimized) shows nothing.

### Restore to the current workspace

Restore dispatches, per window:

```
hyprctl dispatch movetoworkspace <currentWsId>,address:<addr>
hyprctl dispatch focuswindow address:<addr>
```

`<currentWsId>` is the active workspace at click time. **Why current, not origin:**
`special:minimized` records no origin, so "send it back" would require adding
origin bookkeeping to the minimize action plus a state file. "Bring it here" is
predictable, dependency-free, and matches how a taskbar restore usually feels.
"Restore all" iterates the same over every client in `special:minimized`.

### Event-driven refresh, no polling

Connect the same signals `Workspaces.tsx` uses (`client-added`, `client-removed`,
`client-moved`, `notify::workspaces`) to recompute the minimized list, count, and
visibility. This keeps the hide-when-empty behavior and the popover contents in
sync with actual minimize/restore events.

## Risks / Trade-offs

- **[Trade-off] restore target = current workspace.** Not the origin; accepted for
  simplicity and predictability (see Decisions). Documented in the widget.
- **[Risk] special workspace name assumption.** The widget keys off the literal
  name `special:minimized`, which is the name the minimize action uses. If that
  action's target name ever changes, this widget must match it. Low risk (both are
  in this repo); noted in the widget.
- **[Note] popover open while state changes.** If a window is restored while the
  popover is open, the event-driven refresh updates the list; a now-empty popover
  simply has no rows and the indicator hides on close.

## Alternatives Considered

- **Always-visible with a `0` count** — rejected in favor of hide-when-empty; the
  absence of minimized windows is the normal case and needs no bar real estate.
- **Restore to original workspace** — rejected: needs origin tracking that
  `special:minimized` doesn't provide (extra state + changes to the minimize
  action).
- **Put restore in the `Workspaces` widget** — rejected: `Workspaces` intentionally
  only shows `id >= 0` workspaces; a dedicated `end`-cluster indicator is cleaner
  and matches the other status widgets.
