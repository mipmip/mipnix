## 1. Menu entry

- [x] 1.1 Append `"Close menu"` to the `ACTIONS` list (last) in
      `modules/USERS/pim/programs/hyprland/scripts/hypr-longpress`, with a comment
      explaining the no-op fall-through and the last-position placement.

## 2. Verify

- [x] 2.1 Daemon still parses (`python3 -c 'import ast; ast.parse(...)'`).
- [x] 2.2 Confirm "Close menu" matches no `dispatch_action` branch (no-op), and the
      window "Close" still matches — verified by exercising the branch logic.
- [x] 2.3 Fix: adding "Close menu" made 16 entries but the rofi theme capped the
      list at `lines: 15` (with `fixed-height: false`, `scrollbar: false`), so the
      16th entry was clipped and invisible. Changed the theme to `lines: {len(ACTIONS)}`
      so the menu always sizes to every entry (renders `lines: 16` now).
- [x] 2.4 Live: after `up_home` + restart, long-press a window, confirm the
      "Close menu" entry is now VISIBLE at the bottom, and selecting it closes the
      menu without affecting the window. (User to confirm.)
