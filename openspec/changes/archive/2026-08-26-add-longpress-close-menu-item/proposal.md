## Why

The `hypr-longpress` window-action menu can only be dismissed with Escape or by
clicking outside it. This whole feature exists for **mouse-only** use (leaning
back, no keyboard), so requiring a keypress or an off-menu click to back out is
an awkward gap — there is no in-menu, mouse-clickable way to say "never mind,
just close this menu."

## What Changes

- Add a **"Close menu"** entry to the longpress rofi menu. Selecting it simply
  dismisses the menu and dispatches nothing to the window.
- It is placed **last**, deliberately away from the destructive window "Close"
  entry at the top, to avoid misclicks between "close the menu" and "close the
  window."
- Implemented as a no-op: the entry has no branch in `dispatch_action`, so
  selecting it (rofi closes on selection) falls through and does nothing.

## Capabilities

### Modified Capabilities

- `hypr-longpress-window-actions`: the window-action menu now also lists a
  "Close menu" entry that dismisses the menu without acting on the window — a
  mouse-clickable equivalent of Escape / clicking outside.

## Impact

- `modules/USERS/pim/programs/hyprland/scripts/hypr-longpress`: append
  `"Close menu"` to the `ACTIONS` list (last). No `dispatch_action` change needed
  — an unmatched selection is already a no-op.
- No new dependencies; no change to the daemon, packaging, or autostart.
