## Context

mipbar is an Astal/AGS bar (GTK4 + TypeScript/JSX). Its `end` cluster holds small
status widgets — `Camera`, `Screenshare`, `Minimized`, `AllWindows`, `SshKey`,
`SystemMonitor`, `QuickSettings` — each a `menubutton` with a `<popover>`.

Two existing pieces are directly relevant:

- `widget/ScreenPicker.tsx` already renders a rich per-monitor tile: cairo-drawn
  laptop/monitor illustrations, bundled product photos keyed off connector name and
  EDID substrings (`assets/framework-13.svg`, `assets/lg-ultrafine.svg`), model line,
  `SIZE · RES · REFRESH` spec line, accent-coloured port chip, monospace connector tag,
  and a CURRENT pill. It is opened by right-clicking a workspace button and only
  dispatches `moveworkspacetomonitor`.
- `widget/monitors.ts` holds the pure helpers behind that tile: a per-monitor accent
  map with a deterministic djb2 fallback palette, light/dark variants, soft fills,
  `deviceType`, `portType`/`portLabel`, and `specLine`.

Monitor geometry is declared in `modules/USERS/pim/programs/hyprland/hypr/monitors.conf`,
matched by EDID description so one file works across machines. Home Manager installs it
as a read-only `/nix/store` symlink at `~/.config/hypr/monitors.conf`.

## Goals / Non-Goals

**Goals:**
- One place in the bar that answers "what monitors do I have, and what are they doing".
- Change a monitor's resolution without leaving the desktop.
- Always show what is actually true, including when Hyprland silently disagreed with
  the request.
- Get back to the declarative configuration in one click.

**Non-Goals:**
- Persisting anything. `monitors.conf` stays the single source of truth for what a
  monitor does at login.
- Choosing refresh rate, rotation, mirroring, VRR, or HDR. These are shown where useful
  but not controlled.
- Replacing `ScreenPicker` or changing workspace→monitor binding.
- Editing `monitors.conf` from the desktop, by any mechanism.

## Decisions

### Read `hyprctl monitors all -j`, not AstalHyprland

`AstalHyprland.Monitor` exposes most of what is needed reactively — `available-modes`,
`scale`, `transform`, `x`/`y`, `vrr`, `dpms-status`, `current-format`. It was still the
wrong source here, for two measured reasons.

**It cannot report physical size.** The GIR has no `physicalWidth`/`physicalHeight`.
`hyprctl` does (`310`/`170` mm for this laptop panel), and physical size is what turns
a resolution into a diagonal and a DPI figure — the thing that makes the menu
*informative* rather than a restatement of numbers the user already knows.

**It goes stale after an apply, permanently.** AstalHyprland refreshes its monitor
objects from Hyprland's event socket. A spike listened on `.socket2.sock` across a
resolution change and captured nothing; a control `hyprctl reload` in the same window
produced `configreloaded>>`, proving the listener worked. Hyprland simply does not
announce mode changes. An AstalHyprland-backed menu would therefore display the
pre-change resolution as current, indefinitely, immediately after successfully
changing it.

So this widget reads `hyprctl monitors all -j` **on popover open and after every
apply**. On-demand, not polled: the data only changes when the popover is open or when
the user just acted, and a closed popover has nothing to keep fresh.

### Duplicate the card rather than extract it

`ScreenPicker`'s tile is built around `Hyprland.Monitor` getters and its reactive
lifecycle. This menu's cards are built from plain parsed objects and are rebuilt
wholesale on every read. Extracting a shared component would mean either an adapter
layer or a union type threaded through every accessor, to save duplicating layout code
that the two widgets are already free to evolve apart. The accent/port/device helpers
in `monitors.ts` are pure and stay shared; only the tile layout is written twice.

### Predict the scale snap instead of reporting it afterwards

Hyprland requires a scale that yields an integer logical size. When it does not get
one it does **not** error — the spike applied `1280x1024@60.05` at scale `1.5`, got
`ok`, and found the scale had become `1.6`. For this panel that affects **six of its
nine** available modes — only `1920x1080`, `1680x1050` and `1440x900` divide cleanly by
1.5; everything else lands on 1.6. A menu that did not warn would mis-set the scale more
often than not.

This is arithmetic, not a runtime surprise: a mode is clean when `width % scale == 0`
and `height % scale == 0`, and when it is not, the scale Hyprland will choose is
derivable. So every resolution row that will move the scale is annotated with the
resulting scale *before* the click. After the apply, the read-back shows the real
scale and logical size regardless, so a mispredicted snap is visible rather than
hidden.

### Apply keeps the current position and scale

The dispatch is `hyprctl keyword monitor <NAME>,<W>x<H>@<Hz>,<x>x<y>,<scale>`, reusing
the monitor's present `x`/`y` and `scale`. Passing `auto` for either was rejected:
`auto` position relocated a monitor from `2560x0` to `0x0` in the spike, and `auto`
scale picked `1.6` for `1280x720` (an 800×450 logical desktop). Both are surprising as
a side effect of "change the resolution". Position re-packing is available, but only
as the explicit **Re-pack layout** action.

### Reset is `hyprctl reload`

`monitors.conf` is already the declarative truth, and `hyprctl reload` re-reads it.
The spike confirmed an exact restore of resolution, position, and scale, with mipbar
surviving. No shadow state, no remembering what was changed, no undo stack.

### Refresh rate is deduplicated away

`availableModes` is grouped by `WxH`, keeping the highest rate per resolution. A
monitor offering `3840x2160@60` and `3840x2160@30` presents one row and applies `60`.

## Risks / Trade-offs

**Changes do not survive a relogin.** This is the chosen semantic, not an oversight:
a resolution change is a temporary act (a presentation, a screen recording), and
`monitors.conf` should keep winning at login. "Reset to configured" makes the return
trip immediate. It matches `workspace-screen-binding`, which already specifies that
rebinding is runtime-only and writes no configuration.

**Position gaps are user-visible.** `monitors.conf` pins absolute coordinates, so
shrinking the external monitor's logical width strands the laptop panel beyond a dead
region the cursor must traverse. Re-pack layout fixes it on demand; leaving it implicit
would reorder monitors by enumeration rather than by where they physically sit.

**Scale-snap prediction can drift.** It encodes Hyprland's current behaviour, which may
change. The consequence is a wrong or missing annotation, never a wrong applied state —
the post-apply read-back is authoritative.

**Losing nwg-displays removes a rotation/mirroring UI.** It was already non-functional
for saving here, and `hyprctl keyword` remains available for the rare rotation. If
rotation turns out to be missed, adding it to this menu is a small follow-up.

## Migration Plan

1. Land the `Displays` widget and confirm it against a known monitor set.
2. Remove `nwg-displays` from `hyprland.nix` and correct the `workspaces.conf` header.
3. Apply the `hyprland-monitor-topology` delta, coordinating with the in-progress
   `fix-workspace-monitor-binding` change (see proposal Notes).

No data migration; nothing persists.

## Open Questions

None blocking. Rotation and mirroring controls are deferred by decision, not by
uncertainty.
