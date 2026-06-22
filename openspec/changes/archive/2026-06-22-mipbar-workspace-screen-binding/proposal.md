## Why

On a multi-display setup the mipbar workspace pills give no hint of which
monitor a workspace lives on, and there is no way to move a workspace to a
different display from the bar. A design handoff ("Workspace → Screen Binding",
treatment: *Underline*) specifies two additions: a per-workspace monitor
indicator and a right-click screen picker that rebinds the workspace.

This proposal recreates that design inside the existing AGS bar widget, reusing
its `hyprland` service, widget tree and SCSS/theme conventions — no new runtime
dependencies and no web stack.

Design handoff: bundled `design_handoff_workspace_screen_binding/` (preview.html
is the visual source of truth). No existing `.beans` task covers this feature;
it originates from the handoff.

## What Changes

- **Per-workspace monitor underline** — every workspace pill gains a second row:
  a 14×2.5px underline (radius 2px) coloured by the accent of the monitor the
  workspace is currently bound to. Present on empty, occupied and active
  workspaces alike. The button becomes a vertical stack (number/icons row +
  underline row, 4px gap).
- **Right-click screen picker** — secondary-click on a workspace opens a GTK
  `Popover` anchored to the button, listing every connected monitor with a
  device illustration (laptop vs monitor), model name, `SIZE · RES · REFRESH`
  spec line, and a port chip + connector tag. The workspace's current monitor
  row is marked `CURRENT` and accent-bordered.
- **Rebind action** — selecting a row runs
  `hyprland.messageAsync('dispatch moveworkspacetomonitor <N> <NAME>')`, marks
  that row current and closes the popover. **Live (runtime) only** this change;
  persisting a `workspace = N, monitor:NAME` rule into home-manager Hyprland
  config is a documented non-goal / follow-up.
- **Monitor accent system** — a deterministic `monitorAccent(name)`: a
  user-config map (e.g. `{ "DP-1": "#4874d8" }`) with a name-hash → hue
  fallback for unmapped monitors. Plus `deviceType(name)` (eDP/LVDS ⇒ laptop)
  and `portType(name)` (eDP/HDMI/DP prefix) helpers.
- **Reactive updates** — the underline recomputes on `notify::monitors` /
  `notify::workspaces` (monitor add/remove, workspace moved).

## Capabilities

### New Capabilities
- `workspace-screen-binding`: per-workspace monitor underline indicator,
  right-click monitor picker popover, and the live rebind dispatch.

### Modified Capabilities
<!-- None — the existing workspace-navigation capability (visibility, grouping,
     app icons) is unchanged; this adds a new orthogonal capability. -->

## Impact

- **Files modified**: `packages/mipbar/widget/Workspaces.tsx` (button becomes a
  vertical stack with underline; right-click gesture; popover; reactive monitor
  state), `packages/mipbar/style.scss` (underline, popover, picker-row styling),
  `packages/mipbar/theme.ts` (light/dark popover + picker neutrals).
- **Files added**: a small monitor/accent helper module (e.g.
  `packages/mipbar/widget/monitors.ts`) for `monitorAccent` / `deviceType` /
  `portType` / `deviceImage`, and the picker popover component (e.g.
  `packages/mipbar/widget/ScreenPicker.tsx`).
- **No new runtime dependencies**; everything uses the AGS `hyprland` service
  already in use. Nix/home-manager AGS config unchanged.
- **No persistent config writes** in this change (live dispatch only).
