# Add mipbar Displays menu

**Bean**: [mipnix-1j15](../../../.beans/mipnix-1j15--mipbar-displays-menu-with-per-monitor-info-and-res.md)

## Why

There is no way to see what the attached monitors actually *are*, or to change a
monitor's resolution, without dropping to `hyprctl` in a terminal.

`nwg-displays` is installed for this job (`modules/programs/desktop/de/hyprland.nix:97`)
but it cannot work here: it saves by writing `~/.config/hypr/monitors.conf`, which is a
**read-only `/nix/store` symlink** owned by Home Manager. Every save fails. The
`hyprland-monitor-topology` spec nevertheless asserts that nwg-displays "owns monitor
geometry" and "may keep writing" those files — a claim the filesystem contradicts.

mipbar already renders exactly the right card. `widget/ScreenPicker.tsx` draws a
per-monitor tile with a device illustration (or a bundled product photo), model,
spec line, port chip, connector tag, and a per-monitor accent colour. It is reachable
only by right-clicking a workspace button, and its only action is rebinding a
workspace. The presentation work is done; it just has no front door.

### Spike findings

A live spike on `eDP-1` (`hyprctl keyword monitor …`, restored afterwards) established
three facts that shape this design:

1. **mipbar survives a mode change.** No restart, no popover teardown; `app.ts`'s
   `notify::monitors` handler does not fire for geometry-only changes.
2. **Hyprland emits no IPC event for a mode/scale/position change.** A `socat` listener
   on `.socket2.sock` captured nothing across a resolution change, while a control
   `hyprctl reload` in the same window produced `configreloaded>>`. AstalHyprland
   refreshes its monitor objects from that socket, so **its `Monitor` objects go stale
   after an applied change and never recover.**
3. **An invalid scale is not rejected — it is silently substituted.** Applying
   `1280x1024@60.05` at scale `1.5` returned `ok` and quietly changed the scale to
   `1.6` (1280/1.6 = 800 exactly). What the user asked for is not necessarily what
   they got, and nothing reports the difference.

Together (2) and (3) mean a naive menu would show the *old* resolution as current after
a successful change, and would never mention that the scale moved underneath it.

## What Changes

- **New mipbar widget (`Displays`).** A `menubutton` in the bar's `end` cluster, beside
  `SystemMonitor`, opening a popover with one card per attached monitor.
- **Full per-monitor detail.** Model/description, physical diagonal in inches, current
  resolution and refresh, scale and the resulting logical size, native and effective
  DPI, position, connector plus port chip, active workspace, focused marker, and VRR /
  DPMS state. Rotation and mirroring appear only when non-default.
- **Resolution switching, runtime only.** Each card lists the monitor's selectable
  resolutions; clicking one dispatches
  `hyprctl keyword monitor <NAME>,<W>x<H>@<Hz>,<x>x<y>,<scale>`. No Hyprland
  configuration is written, matching the precedent already set by
  `workspace-screen-binding`'s `live-rebind-action`.
- **Read-back after apply.** State is read from `hyprctl monitors all -j` when the
  popover opens and again after every apply, so the card always reflects reality rather
  than the request — the direct consequence of spike findings (2) and (3).
- **Pre-flight scale warning.** Because Hyprland's scale substitution is predictable
  arithmetic, a resolution that will not divide evenly by the current scale is annotated
  up front with the scale Hyprland will snap to, instead of surprising the user after
  the fact.
- **"Reset to configured".** Runs `hyprctl reload`, restoring every monitor to the
  declarative `monitors.conf` state. Spike-verified as an exact restore.
- **"Re-pack layout".** `monitors.conf` pins absolute positions, so shrinking a
  monitor's logical width leaves a dead gap the cursor must cross. This action re-applies
  each monitor with `auto` position to close it. Offered explicitly rather than applied
  implicitly, because `auto` orders by enumeration, not by physical desk layout.
- **Retire nwg-displays.** Removed from `hyprland.nix`; the `coexist-with-nwg-displays`
  requirement is renamed and rewritten to drop the false attribution.

## Capabilities

### New Capabilities

- `mipbar-displays-menu`: A mipbar menu surfacing full detail for every attached monitor
  and switching resolution per monitor at runtime, with truthful read-back and a reset
  to the declarative configuration.

### Modified Capabilities

- `hyprland-monitor-topology`: `coexist-with-nwg-displays` is renamed to
  `static-config-owns-no-dynamic-binding` and rewritten to state the actual invariant —
  static configuration owns monitor geometry, runtime reconciliation owns the
  workspace→monitor binding — without crediting a tool that is being removed and could
  never write those files.

## Impact

- `packages/mipbar/widget/Displays.tsx`: new widget — `hyprctl monitors all -j` reader,
  monitor cards, resolution rows, reset and re-pack actions.
- `packages/mipbar/widget/displayInfo.ts`: new pure helpers — JSON parsing, mode
  deduplication, scale-snap prediction, diagonal/DPI derivation. No GTK imports, in the
  style of `widget/monitors.ts`.
- `packages/mipbar/widget/Bar.tsx`: import `Displays`, add `<Displays />` to the `end`
  box before `<SystemMonitor />`.
- `packages/mipbar/style.scss`: `.Displays` StatusIcon plus `.DisplaysPopover` and card
  styling, following the existing `.ScreenPicker` idiom.
- `modules/programs/desktop/de/hyprland.nix`: drop `nwg-displays` from the package list.
- `modules/USERS/pim/programs/hyprland/hypr/workspaces.conf`: replace the
  `# Generated by nwg-displays … Do not edit manually.` header, which becomes false once
  the generator is gone.
- No change to `monitors.conf`, to Hyprland's declarative configuration, or to the
  workspace→monitor reconciliation script.

## Notes

- **Deliberate duplication.** The monitor card is written fresh rather than extracted
  from `ScreenPicker.tsx`. The two consume different data: `ScreenPicker` holds reactive
  `Hyprland.Monitor` GObjects, this menu holds plain objects parsed from `hyprctl` —
  which is the only source for physical dimensions, mirroring, and post-apply truth.
  Forcing one component to serve both shapes would couple a reactive widget to a
  polled one for no gain.
- **`specLine()`'s missing field.** `widget/monitors.ts` documents size as "unknown from
  Hyprland (no physical dimensions)". That is true of AstalHyprland but not of
  `hyprctl`, which reports `physicalWidth`/`physicalHeight` in millimetres. The `SIZE`
  slot in the existing `SIZE · RES · REFRESH` format is finally fillable.
- **Refresh rate is not a user choice.** `availableModes` is deduplicated by resolution,
  keeping the highest rate per resolution.
- **Ordering dependency.** The in-progress change `fix-workspace-monitor-binding` also
  modifies `coexist-with-nwg-displays`. OpenSpec deltas express intent and are merged
  intelligently, so both can apply — but whichever archives second must be reread
  against the then-current main spec. If `fix-workspace-monitor-binding` archives after
  this change, its delta must be rebased onto the renamed requirement and its
  nwg-displays sentences dropped.
- **`hyprviz` is left alone.** It sits two lines above `nwg-displays` in
  `hyprland.nix` and overlaps in purpose, but it is a general Hyprland configuration
  GUI rather than a display-geometry tool, and nothing here establishes that it is
  broken. Removing it is a separate decision.
