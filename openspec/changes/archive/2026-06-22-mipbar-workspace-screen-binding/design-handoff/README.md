# Handoff: Workspace → Screen Binding

## Overview
Adds two capabilities to the existing AGS + Hyprland workspace bar:

1. **Per-workspace monitor indicator** — every workspace pill shows a thin underline in the colour of the monitor it is currently bound to, so a multi-display layout is readable at a glance.
2. **Right-click screen picker** — right-clicking a workspace opens a context menu listing every connected display with a product image of the device (laptop vs monitor), its model, size, resolution, refresh rate and connection port. Selecting a row rebinds the workspace to that monitor.

The chosen visual treatment is **"Underline"** (the lowest-density of the three explored). This document plus the bundled HTML is everything needed to implement it.

## About the Design Files
The files in this bundle are **design references created in HTML** — a prototype showing the intended look and behaviour. They are **not** code to copy into the shell.

Your target is the user's existing **AGS** setup (Aylur's GTK Shell — GJS + GTK, styled with GTK CSS / SCSS), managed declaratively on **NixOS**. The task is to **recreate this design inside that existing AGS bar widget**, following its established patterns (its widget tree, its `hyprland` service usage, its SCSS/CSS variables, its existing workspace button component). Reuse what's already there; do not introduce a web stack.

Notes specific to this environment:
- **Colour functions:** the prototype uses `oklch()`. GTK 4's CSS does support some modern colour syntax, but for safety every token below is also given as a resolved **hex**. Prefer feeding these through the existing theme/SCSS variables.
- **Backdrop blur:** the prototype's frosted-glass bar uses `backdrop-filter`, which GTK CSS does **not** support. The real bar's translucency comes from the compositor (Hyprland `layerrule blur`/`ignorealpha` on the AGS layer). Keep the existing bar background; only the *new* sub-elements below are in scope.
- **NixOS:** if any new runtime dependency is needed (none should be — everything uses `hyprctl` / the AGS `hyprland` service already in use), add it through the user's existing flake/home-manager AGS config rather than imperatively.

## Fidelity
**High-fidelity.** Colours, sizes, typography, spacing and copy below are final. Recreate the underline indicator and the picker pixel-faithfully using GTK widgets; match the measurements.

---

## Screens / Views

### 1. Workspace bar — underline indicator (always visible)
**Purpose:** show, per workspace, which monitor it lives on.

**Layout:** unchanged from today — a horizontal row: the app-grid launcher on the left, then the workspace buttons. The only change is *inside each workspace button*.

**Each workspace button becomes a vertical stack (GTK `box`, orientation vertical, spacing 4px, centred):**
- Row 1 (existing): optional app icon (13px) + the workspace number.
- Row 2 (**new**): an underline bar — width **14px**, height **2.5px**, border-radius **2px**, background = **the bound monitor's accent colour**.

Button padding `5px 9px`, border-radius `9px`. The underline is present on **every** workspace (empty, occupied and active alike) — it is the indicator.

State backgrounds (unchanged behaviour, listed for completeness):

| State | Light bg | Dark bg | Number colour (light / dark) |
|---|---|---|---|
| Active (focused) | `#babac2` | `#797986` | `#2d2d35` / `#f5f5f8` |
| Occupied (has windows) | `#ddddea` (85%) | `#47474e` (60%) | `#2d2d35` / `#f5f5f8` |
| Empty | transparent | transparent | `#5a5a61` / `#a4a4ab` |

App-icon stroke colour: `#41414d` (light) / `#dddde3` (dark).

### 2. Right-click screen picker (popover/menu)
**Purpose:** rebind the right-clicked workspace to another connected display.

Triggered by a **right-click (secondary button press)** on any workspace button. Implement as a GTK `Popover` (preferred — supports rich rows + images) anchored to the clicked button, or a `Menu` if you want native menu behaviour. The prototype anchors a downward caret to the workspace; a `Popover.set_pointing_to(button)` gives the equivalent.

**Container:** width ~**320px**, padding **6px**, border-radius **14px**, 1px border, drop shadow.
- Light: bg `#ffffff`, border `#ece8e0`, shadow `0 18px 44px -10px rgba(20,20,40,.38)`
- Dark: bg `#18181e`, border `#323238`, shadow `0 18px 44px -10px rgba(0,0,0,.6)`

**Header row:** padding `8px 9px`, text `WORKSPACE <N> · BOUND TO SCREEN`, uppercase, 9px, weight 700, letter-spacing .1em, colour `#a7a299` (light) / `#85858c` (dark).

**One row per connected monitor** (`box`, horizontal, gap 12px, padding `9px 12px`, margin-bottom 5px, border-radius 11px):
- **Product image** (left, flex-none): see "Device product image" below. ~58×42px.
- **Text column** (gap 4px):
  - **Line 1:** model name (`description` from Hyprland), 13px / weight 700, colour `#2d2d35` (light) / `#f1f1f4` (dark). If this is the workspace's current monitor, append a **"CURRENT"** pill: 8.5px / 700 uppercase, text = accent, bg = accent @ 15% (light) / 26% (dark), padding `2px 7px`, radius 999px.
  - **Line 2:** spec line `SIZE · RES · REFRESH` (e.g. `27" · 3840×2160 · 60 Hz`), 11px / weight 500, muted `#8a857c` (light) / `#85858c` (dark).
  - **Line 3:** a port chip + connector tag. Chip: `box` with port icon (14px, accent-stroked) + port label (10.5px / 600, colour = accent), padding `3px 8px 3px 6px`, radius 999px, bg = accent @ 15%/26%. Connector tag (e.g. `DP-1`): 10.5px / 600 monospace, colour `#b3aea4` (light) / `#85858c` (dark).

**Row container styling:**
- **Selected (current monitor):** bg = accent @ 12% (light) / 22% (dark); border `1.5px solid <accent>`.
- **Other rows:** bg `#f6f6f9` (light) / `#242328` (dark); border `1.5px solid #e7e7ea` (light) / `#323238` (dark).

**Device product image:** a stylised device illustration (à la macOS *Displays*), tinted by the monitor's accent. The prototype draws it as inline SVG; in GTK render it as a small `Gtk.DrawingArea`/`cairo` drawing, an asset `Gtk.Image`, or an SVG icon. Two variants keyed off device type:
- **Monitor** (`device !== eDP`): dark bezel `#23262c` rounded rect (screen), inner screen filled with a dark accent tint, a 2.5px accent "glow" line along the screen's bottom edge, plus a neck + base in `#3a3d44`.
- **Laptop** (`eDP*` / internal): same bezel+screen+glow as the lid, with a trapezoidal keyboard base in `#3a3d44`.
- Screen tint = `oklch(0.33 0.08 <hue>)` per monitor → eDP `#0d401e`, DP `#20335e`, HDMI `#502b00` (or just darken the accent ~55%). Glow line = the accent. **The image may be swapped for a real product photo** matched on the model string later — keep it behind a small `deviceImage(monitor)` helper.

---

## Interactions & Behavior
- **Indicator update:** recompute a workspace's underline colour whenever Hyprland reports a workspace moving monitors or a monitor (dis)connecting. Listen to the AGS `hyprland` service `notify::monitors` / `notify::workspaces` (or the events `monitoradded`, `monitorremoved`, `moveworkspace`, `focusedmon`).
- **Open picker:** secondary (right) mouse button press on a workspace button → open the popover for that workspace. Use a `Gtk.GestureClick` with `button = 3` (or AGS `onSecondaryClick`).
- **Select a screen:** clicking a row runs the rebind (below), marks that row current, and closes the popover.
- **Hover:** rows lighten slightly on hover (optional, matches GTK defaults). The "current" row keeps its accent border regardless.
- **No animation requirements** beyond the popover's native fade. Underline colour changes can be instant.

## Rebind action (the actual feature)
Selecting monitor `NAME` for workspace `N`:
```sh
hyprctl dispatch moveworkspacetomonitor <N> <NAME>
```
- Prefer the AGS `hyprland` service's `messageAsync('dispatch moveworkspacetomonitor <N> <NAME>')` over shelling out.
- This binding is **runtime only**. To make it survive a reconnect/relogin, also persist a `workspace = N, monitor:NAME` rule into the user's Hyprland config (via their NixOS/home-manager Hyprland settings). Confirm with the user whether they want the persistent rule written, or just the live dispatch.

## State Management
Per render the bar needs, from `hyprctl monitors -j` (or the `hyprland` service):
- `monitors[]`: `{ name, description, width, height, refreshRate, /* derive */ size?, port }`
- `workspaces[]`: `{ id, monitor }` → map workspace id → monitor name → accent.
- `activeWorkspace` / focused workspace id.

Derived state:
- **`monitorAccent(name)`** — stable colour per monitor. Use a user-config map first (e.g. `{ "DP-1": "#4874d8" }`), falling back to a hash of the monitor name → hue. Must be deterministic across reloads.
- **`deviceType(name)`** — `eDP*`/`LVDS*` ⇒ laptop, else monitor.
- **`portType(monitor)`** — infer from connector prefix: `eDP` ⇒ internal, `HDMI` ⇒ HDMI, `DP` ⇒ DisplayPort. USB-C (DP alt-mode) also enumerates as `DP-N`; if you need to distinguish true USB-C, cross-reference `/sys/class/drm/.../`. The prototype shows USB-C on `DP-1` as an example — treat the port label as best-effort.

## Design Tokens

### Monitor accents (example mapping — real values come from `monitorAccent()`)
| Monitor | Light | Dark | Hue |
|---|---|---|---|
| eDP-1 (laptop) | `#429c5a` | `#5fb875` | green 150 |
| DP-1 (Dell, USB-C) | `#4874d8` | `#6291f7` | blue 264 |
| HDMI-A-1 (Samsung) | `#ea952d` | `#ffb250` | amber 66 |

Dark accent = light accent with lightness +0.09 (brighter for dark bg). Soft fills used for chips/tiles/"current" pill = accent at **15% (light) / 26% (dark)** alpha; selected tile bg = accent at **12% / 22%**.

### Neutrals
| Token | Light | Dark |
|---|---|---|
| Workspace number (active/occupied) | `#2d2d35` | `#f5f5f8` |
| Workspace number (empty) | `#5a5a61` | `#a4a4ab` |
| App icon stroke | `#41414d` | `#dddde3` |
| Pill bg — active | `#babac2` | `#797986` (78%) |
| Pill bg — occupied | `#ddddea` (85%) | `#47474e` (60%) |
| Popover bg | `#ffffff` | `#18181e` |
| Popover border | `#ece8e0` | `#323238` |
| Popover text | `#2d2d35` | `#f1f1f4` |
| Popover muted | `#8a857c` | `#85858c` |
| Connector mono tag | `#b3aea4` | `#85858c` |
| Tile bg (non-current) | `#f6f6f9` | `#242328` |
| Tile border (non-current) | `#e7e7ea` | `#323238` |
| Device bezel | `#23262c` | `#23262c` |
| Device stand | `#3a3d44` | `#3a3d44` |
| Screen tint (eDP / DP / HDMI) | `#0d401e` / `#20335e` / `#502b00` | same |

### Sizes / spacing
- Underline: `14 × 2.5px`, radius `2px`. Gap between number row and underline: `4px`.
- Workspace button: padding `5px 9px`, radius `9px`.
- App / workspace icon: `13px`.
- Popover: width `~320px`, padding `6px`, radius `14px`.
- Picker row: gap `12px`, padding `9px 12px`, margin-bottom `5px`, radius `11px`, border `1.5px`.
- Product image: `~58 × 42px`.
- Port icon: `14px`. Port/spec text: `10.5–11px`. Model: `13px`.

### Typography
System UI sans for all labels; **monospace** only for the connector tag (`DP-1`) and any `hyprctl` strings. Weights: 700 (model, header, "CURRENT"), 600 (number, port label, connector), 500 (spec line).

## Assets
- **Device product images** are generated illustrations in the prototype (no external files). Implement as cairo drawing / SVG, or replace with real photos keyed on model string. No third-party icon set is required — app icons and port icons are simple inline glyphs you can map to your existing icon source.

## Files
- `preview.html` — **self-contained, open this in a browser** to see the design (light + dark, picker open). This is the visual source of truth.
- `Workspace Screen Binding.dc.html` — the editable source of the prototype (a Design Component; needs the authoring runtime to render — use `preview.html` to view).
