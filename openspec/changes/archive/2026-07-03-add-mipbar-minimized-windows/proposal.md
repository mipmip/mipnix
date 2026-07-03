## Why

Windows can be minimized (the mipbar `hypr-longpress` action's "Minimize" moves a
window to the `special:minimized` special workspace via
`movetoworkspacesilent special:minimized,<addr>`). But there is **no interface
to see which windows are minimized or to un-minimize them** — they vanish from
every workspace and from the bar. The only recovery today is guessing a raw
`hyprctl` dispatch in a terminal. (At time of writing, two windows are stranded
in `special:minimized` with no way to reach them.)

mipbar already hosts a row of small status indicators in its `end` cluster and a
`Workspaces` widget that reads live Hyprland client/workspace state, so a
minimized-windows indicator fits the existing surface and patterns.

## What Changes

- **New mipbar widget (`Minimized`).** A small indicator in the bar's `end`
  cluster that:
  - **Hides when nothing is minimized** (like `Camera`), so it adds no clutter in
    the common case.
  - When ≥1 window is in `special:minimized`, shows an icon plus the **count**.
  - **Click opens a popover** listing each minimized window (app icon + title).
    Clicking a row **restores** that window to the **current** workspace and
    focuses it. A "Restore all" action restores every minimized window.
- **Restore = bring-it-here.** Restore dispatches
  `movetoworkspace <currentWsId>,address:<addr>` then `focuswindow address:<addr>`,
  pulling the window to the active workspace. (The original workspace is not
  tracked; "current workspace" is the predictable, dependency-free behavior.)
- **Live updates.** State refreshes on the same AstalHyprland events the
  `Workspaces` widget uses (`client-added`/`-removed`/`-moved`,
  `notify::workspaces`), so the count/list and the hide-when-empty visibility
  stay current without polling.

## Capabilities

### New Capabilities

- `mipbar-minimized-windows`: A mipbar indicator that reveals windows minimized
  to the `special:minimized` workspace and lets the user restore them (to the
  current workspace) from a popover — the missing counterpart to the Minimize
  action.

## Impact

- `packages/mipbar/widget/Minimized.tsx`: new widget — AstalHyprland +
  `get_workspaces()`/`get_clients()` to read `special:minimized`, `lookupIcon`
  for icons, a `menubutton` popover with per-window restore rows + "Restore all",
  event-driven refresh, hidden when empty.
- `packages/mipbar/widget/Bar.tsx`: import `Minimized` and add `<Minimized />` to
  the `end` `<box>` (alongside Camera/Screenshare/SshKey/SystemMonitor).
- `packages/mipbar/style.scss`: `.Minimized` StatusIcon styling + `.MinimizedPopover`
  (reusing the existing popover / `StatusRow` idiom).
- No change to the minimize action itself, Hyprland config, or the
  `special:minimized` mechanism; this widget only reads that workspace and
  dispatches restore commands.

## Notes

- Restoring to the current workspace (not the origin) is deliberate: Hyprland's
  `special:minimized` does not record where a window came from, and "bring it to
  where I am" is the most predictable behavior. Tracking origin would require
  extra bookkeeping in the minimize action and a state file — out of scope.
