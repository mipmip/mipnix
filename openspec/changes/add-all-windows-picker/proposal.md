<!-- Bean: .beans/mipnix-zsgz--dropdown-in-mipbar-showing-all-applications-on-all.md -->

## Why

A window can end up somewhere mipbar cannot show it, and there is then no way to
reach it from the bar at all.

mipbar's window inventory is a **fixed allowlist of ten workspace ids**
(`Workspaces.tsx:24`, `WORKSPACE_IDS = [1..9, 0]`), but Hyprland's workspace space is
open-ended. Anything outside the allowlist is invisible:

```
Hyprland's actual workspaces         mipbar's inventory
────────────────────────────         ──────────────────
 1   ● ghostty              ──────▶    [1 ●]
 8   (empty)                ──────▶    [8]
10   ● ghostty                 ✗       never drawn
special:minimized           ──────▶    Minimized popover
special:<anything else>        ✗       never drawn
11, 12, name:foo, …            ✗       never drawn
```

Observed live on doornappel during `/opsx:explore mipnix-zsgz`: a ghostty window on
workspace id 10, on a connected monitor, absent from the bar and unreachable from it.

Escape hatches that put a window outside the allowlist:

| Route | Where |
|-------------------------------------------------|-----------------------------|
| 3-finger horizontal swipe past workspace 9 | `hypr/inputs.conf:22` |
| `MOD+0` dispatching an unaddressable id | fixed by `fix-workspace-zero-identity` |
| Workspace bound to a disconnected monitor | `hypr/workspaces.conf` pins 1–7 |
| Special workspaces other than `minimized` | `Minimized.tsx:19` hardcodes one name |
| App- or script-dispatched named workspaces | unconstrained |

`fix-workspace-zero-identity` closes the second row. This change is the safety net for
all the others, including ones not yet imagined — which is why the list must be
derived from the complete client set rather than from any enumeration of workspaces.

## What Changes

- **New mipbar widget: an all-windows picker.** A bar indicator opening a popover
  that lists *every* Hyprland client, flat, one row per window with app icon and
  title — no grouping, no per-row status markers.
- **Two actions per row.** Left-click goes to the window (switch to its workspace and
  focus it). Right-click brings the window to the current workspace and focuses it —
  the rescue path for a window whose workspace is on a disconnected monitor, where
  going to it achieves nothing.
- **Derived, not enumerated.** The list SHALL come from the compositor's full client
  set, so a window on any workspace — numbered, named, or special — appears without
  the widget knowing that workspace exists.

## Capabilities

### New Capabilities

- `mipbar-window-picker`: a flat, exhaustive list of all open windows in the bar,
  with go-to and bring-here actions, whose completeness does not depend on any
  workspace allowlist.

## Impact

- `packages/mipbar/widget/` — new widget file. Closely modelled on `Minimized.tsx`,
  which already has the popover + `For` + Hyprland-signal + `lookupIcon` shape.
- `packages/mipbar/widget/Bar.tsx` — add to the `end` cluster.
- `packages/mipbar/style.scss` — styles for the indicator and rows.

## Design questions settled during exploration

- **Flat, not grouped by workspace**, and **no markers** distinguishing rows whose
  workspace is unreachable. The user reads the list and decides.
- **Left-click go-to / right-click bring-here.** `Workspaces.tsx:103-108` already
  establishes the secondary-click pattern in this codebase (`Gtk.GestureClick` with
  `set_button(Gdk.BUTTON_SECONDARY)`), used there for the screen picker.
- **Minimized windows are included** — the list is "everything", so windows on
  `special:minimized` appear too. Left-click on such a row cannot meaningfully "go
  to" a special workspace, so it degrades to bring-here. The existing `Minimized`
  widget stays as-is; overlap between the two lists is accepted.

## Out of Scope

- Replacing or merging the `Minimized` widget.
- Search/filter in the popover. Worth revisiting if the list gets long enough to be
  unwieldy; the alternative vehicle would be a walker window-switch mode, which
  trades the bar's always-visible discoverability for typeahead.
- Closing the underlying gap by making the bar render unexpected workspaces as extra
  pills. This change is deliberately the safety net, not the hole-plug.
