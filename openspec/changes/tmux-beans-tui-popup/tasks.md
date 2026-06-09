## 1. Add the keybinding

- [x] 1.1 Added `bind B popup -E -w 90% -h 90% 'beans tui'` after the `bind T` popup in `modules/USERS/pim/programs/tmux/default.nix`.

## 2. Build and verify

- [x] 2.1 Built `pim@lego2` (`--impure`, exit 0); verified the bind landed at `~/.config/tmux/tmux.conf:82` → `bind B popup -E -w 90% -h 90% 'beans tui'`.
- [ ] 2.2 Deploy + reload tmux; press `prefix + B` and confirm a ~90% popup opens running `beans tui` in the active pane's directory.
- [ ] 2.3 Confirm the popup closes when `beans tui` exits, and that `prefix + b` (status-bar toggle) and other binds still work.
