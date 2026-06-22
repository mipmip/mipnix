## Context

Mipbar's `Workspaces.tsx` renders a fixed list `[1..9, 0]` of workspace buttons
from the AGS `AstalHyprland` service (`Hyprland.get_default()`), reacting to
`notify::workspaces` and `client-*` signals via `createState`/`For`. Each button
is currently a single horizontal `box` (number label + app-icon images) and
dispatches `hyprctl dispatch workspace <id>` on click. Styling is split:
`style.scss` (base) + `theme.ts` (dark/light string overrides via
`getThemeCss(isDark)`).

The handoff adds an orthogonal concern — *which monitor each workspace is bound
to* — surfaced as an always-visible underline and an on-demand picker. The
existing workspace-navigation behaviour (visibility, grouping, app icons) is
untouched.

GTK constraints from the handoff: no `backdrop-filter` (bar translucency stays a
compositor concern); `oklch()` is risky, so all tokens are also given as hex and
fed through theme/SCSS. The device illustration is a stylised drawing, not an
external asset.

## Goals / Non-Goals

**Goals:**
- Per-workspace underline coloured by the bound monitor's accent, on every
  workspace, updating reactively on monitor/workspace changes.
- Right-click popover listing connected monitors with device image, model, spec
  line, port chip + connector tag; current monitor marked.
- Selecting a row rebinds the workspace live via the `hyprland` service.
- Deterministic `monitorAccent()` (config map + hash fallback), stable across
  reloads.
- Pixel-faithful to the handoff measurements (high-fidelity).

**Non-Goals:**
- **Persisting** the binding into Hyprland/home-manager config (a future phase;
  this change is live-dispatch only — see Decision 5).
- Real product photos for the device image (kept behind a `deviceImage()`
  helper so they can be swapped in later).
- Distinguishing true USB-C from DP alt-mode (port label is best-effort).
- Changing workspace order, grouping, or the existing app-icon behaviour.

## Decisions

### 1. New capability, not a modification of workspace-navigation

**Decision**: Track this as a new `workspace-screen-binding` capability. The
existing `workspace-navigation` spec (visibility, group-by-monitor, app icons)
stays as-is; this is orthogonal behaviour layered onto the same buttons.

**Rationale**: Keeps the delta clean — no existing scenarios are modified, only
new ones added. The two capabilities can evolve independently.

### 2. Workspace button becomes a vertical stack

**Decision**: Wrap the existing horizontal row (number + app icons) and a new
underline element in a vertical `box` (spacing 4px, centred). Underline:
14×2.5px, radius 2px, `background = monitorAccent(boundMonitor)`. Button padding
`5px 9px`, radius `9px`. Underline present on all states (empty/occupied/active).

### 3. `monitorAccent()` — config map + deterministic hash fallback

**Decision**: A helper module exposes `monitorAccent(name, isDark)`:
1. Look the name up in a user-config map (e.g.
   `{ "DP-1": "#4874d8", "eDP-1": "#429c5a", "HDMI-A-1": "#ea952d" }`).
2. Otherwise hash the monitor name → hue, build an OKLCH/HSL colour at fixed
   L/C, resolve to hex.
Dark variant = light accent with lightness +0.09. Soft fills derive at 15%/26%
(chips, CURRENT pill) and 12%/22% (selected tile) alpha.

**Rationale**: Matches the handoff. The map gives the user stable, chosen
colours per known display; the hash keeps unknown monitors deterministic across
reloads (no per-session randomness).

### 4. Picker as a `Gtk.Popover` anchored to the button

**Decision**: Use a `Gtk.Popover` with `set_pointing_to(button)` rather than a
native `Menu`, to support rich rows (image + multi-line text + chips). Opened by
a `Gtk.GestureClick` with `button = 3` (secondary) on the workspace button —
distinct from the existing primary-click `workspace <id>` dispatch. Container
~320px wide, padding 6px, radius 14px, 1px border + shadow (light/dark tokens).
One row per `hyprland.get_monitors()` entry.

### 5. Rebind is live-only this change

**Decision**: Selecting monitor `NAME` for workspace `N` calls
`hyprland.messageAsync('dispatch moveworkspacetomonitor ' + N + ' ' + NAME)`,
then updates the popover (mark row current) and closes it. No write to Hyprland
config.

**Rationale**: User chose "live now, persist as future phase." Persisting means
writing a declarative `workspace = N, monitor:NAME` rule into home-manager,
which fights NixOS immutability and needs its own design. Capturing it as a
non-goal keeps this change shippable and self-contained.

### 6. Device image as a drawn illustration behind a helper

**Decision**: `deviceImage(monitor)` returns a small (~58×42px) widget —
`Gtk.DrawingArea`/cairo or an SVG `Gtk.Image` — with two variants: monitor
(bezel + screen + accent glow + neck/base) and laptop (lid + trapezoidal
keyboard). Screen tint per port family (eDP `#0d401e` / DP `#20335e` / HDMI
`#502b00`, or accent darkened ~55%); glow line = accent.

**Rationale**: The handoff explicitly allows swapping in real photos keyed on
the model string later; isolating it behind one helper makes that a localized
change.

### 7. Reactive monitor↔workspace mapping

**Decision**: Build `workspaceId → monitorName → accent` per render from the
`hyprland` service (`get_workspaces()[].monitor`, `get_monitors()`). Recompute
on `notify::monitors` and `notify::workspaces` (covers monitoradded/removed,
moveworkspace, focusedmon) in addition to the existing `client-*` refreshes.

## Risks / Trade-offs

- **[GTK fidelity]** Reproducing the prototype's CSS (oklch, soft-alpha fills,
  shadows) in GTK4 CSS may differ subtly. → Mitigation: hex tokens provided;
  accept close-but-not-identical where GTK CSS lacks a feature.
- **[Port detection]** USB-C vs DP alt-mode is ambiguous from the connector
  name. → Accepted: port label is best-effort, as the handoff states.
- **[Live-only rebind]** Binding resets on relogin/reconnect to Hyprland config
  defaults. → Accepted and documented; persistence is a follow-up.
- **[Drawn device image]** Cairo drawing is more code than an asset. → Mitigation:
  kept behind `deviceImage()`; can swap to `Gtk.Image` assets/photos later.
- **[Gesture collision]** Adding a secondary-click gesture must not break the
  existing primary-click `workspace <id>` switch. → Mitigation: separate
  `GestureClick` filtered to button 3.
