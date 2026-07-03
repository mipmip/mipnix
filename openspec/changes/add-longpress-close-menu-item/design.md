## Context

The `hypr-longpress` daemon (`modules/USERS/pim/programs/hyprland/scripts/hypr-longpress`)
builds its rofi menu from an `ACTIONS` list and maps a selection to a `hyprctl`
dispatch in `dispatch_action(selection, window_addr)` via an `if/elif` chain.
Selections that match no branch (and `dispatch_action` returns early on empty
selection) result in no dispatch. rofi closes as soon as an entry is selected.

## Goals / Non-Goals

**Goals:**
- A mouse-clickable way to dismiss the menu from within it.

**Non-Goals:**
- Changing the existing Escape / click-outside dismissal (both stay).
- Any change to the window actions themselves or their dispatch.

## Decisions

### Implement as a no-op menu entry, not a special code path

Add `"Close menu"` to `ACTIONS`. Because `dispatch_action` only acts on
recognized selections, a "Close menu" selection falls through the `if/elif`
chain and dispatches nothing — rofi has already closed by then. No new branch,
no state, minimal surface.

### Place it last

The destructive window **Close** is the first entry. Putting "Close menu"
adjacent to it would invite fat-finger misclicks between "close the menu" and
"close the window." Last position keeps the two well separated. (The two are also
worded distinctly: "Close" vs "Close menu".)

## Risks / Trade-offs

- **[Risk] label confusion "Close" vs "Close menu".** Mitigated by distinct
  wording and non-adjacent placement (first vs last). Acceptable.
- **[Note] matching.** `dispatch_action` matches "Close" with `==` (exact), and
  the only prefix match is `startswith("Move to WS ")`; "Close menu" hits neither,
  so it is correctly inert. Verified.

## Alternatives Considered

- **A dedicated `dispatch_action` branch that explicitly does nothing** — rejected
  as redundant; the fall-through no-op is simpler and self-evidently safe.
- **Relying only on Escape / click-outside** — the status quo; rejected because it
  is not mouse-in-menu accessible, which is the point of this feature.
