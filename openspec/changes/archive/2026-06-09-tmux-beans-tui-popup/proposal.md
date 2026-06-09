## Why

The `beans` task manager (the CLI behind this repo's `.beans/*.md` tasks) has an
interactive TUI (`beans tui`), but reaching it means dropping to a shell and typing the
command. A tmux popup keybind gives instant, overlay access to the task TUI from any pane
without disrupting the current layout — matching how other TUIs are already launched in
this tmux config (`prefix+T` for `tj`, `prefix+S` for `smg`).

Related task: [mipnix-tn0f](.beans/mipnix-tn0f--add-tmux-shortcut-which-shows-large-popup-with-bea.md)

## What Changes

- Add a tmux keybinding `prefix + B` that opens a large (90% × 90%) `display-popup`
  running `beans tui`, in the active pane's current directory, closing when the TUI exits.

## Capabilities

### New Capabilities

- `tmux-beans-popup`: A tmux keybinding (`prefix + B`) opens the `beans tui` interactive
  task manager in a large centered popup over the current session.

## Impact

- `modules/USERS/pim/programs/tmux/default.nix`: add one `bind B popup ...` line near the
  existing popup binds (`bind S`, `bind T`, `bind P`).
- No new packages — `beans` is already on PATH (system package at
  `/run/current-system/sw/bin/beans`).
- `prefix + B` (uppercase) is currently unbound (only lowercase `b` is used, for the
  status-bar toggle), so no existing binding is displaced.
