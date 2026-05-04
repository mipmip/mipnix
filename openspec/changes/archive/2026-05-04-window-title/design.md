# Design: Window Title

## Context

The bar's center section is currently an empty box. We need to show the focused window's icon and title, using the existing AstalHyprland library.

## Goals / Non-Goals

**Goals**:
- Show icon + title of focused window in the center
- Reactive updates on focus change and title change
- Truncate with ellipsis for long titles
- Hide when nothing is focused

**Non-Goals**:
- Click interactions
- Showing class name instead of title

## Decisions

### Use hyprland.focusedClient binding

Bind to `createBinding(hyprland, "focusedClient")` for the reactive client reference, then bind to `client.title` for the window title.

**Why**: Same reactive pattern used throughout the codebase. `focusedClient` updates on window switch, and `title` updates when the window changes its title.

### Extract lookupIcon to a shared utility

Move the `lookupIcon()` function from `Workspaces.tsx` to a shared location (or import it) so WindowTitle can reuse it for resolving app icons from WM class names.

**Why**: Avoids duplicating the icon resolution logic. Both widgets need the same class-to-icon mapping.

### Use CSS text-overflow for truncation

Set `max-width`, `overflow: hidden`, and `text-overflow: ellipsis` equivalent via GTK CSS on the title label.

**Why**: Pure CSS approach, no JS truncation logic needed. GTK4 labels support ellipsizing natively via the `ellipsize` property.

### Use label ellipsize property

Set `ellipsize={Pango.EllipsizeMode.END}` and a `maxWidthChars` on the label widget.

**Why**: GTK/Pango handles this natively and more reliably than CSS text-overflow.

## Risks / Trade-offs

[Risk] `focusedClient` may be null between window switches → Mitigation: Hide widget when client is null.

## Open Questions

None.
