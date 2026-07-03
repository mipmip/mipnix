## 1. Menu entry

- [x] 1.1 Append `"Close menu"` to the `ACTIONS` list (last) in
      `modules/USERS/pim/programs/hyprland/scripts/hypr-longpress`, with a comment
      explaining the no-op fall-through and the last-position placement.

## 2. Verify

- [x] 2.1 Daemon still parses (`python3 -c 'import ast; ast.parse(...)'`).
- [x] 2.2 Confirm "Close menu" matches no `dispatch_action` branch (no-op), and the
      window "Close" still matches — verified by exercising the branch logic.
- [ ] 2.3 Live: after `up_home` + restart, long-press a window, select "Close menu",
      confirm the menu closes and the window is unaffected. (User to confirm.)
