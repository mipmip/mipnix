## Why

`hup`'s multiplex switcher drops you into a brand-new tmux window with a single
full-size pane, so every repo you open starts with the same manual splitting
before it is usable. The switcher already owns window creation, so it is the
natural place to hand over a ready-to-work window instead.

## What Changes

- Windows that `hup-tmux-switch` **creates** are arranged into three panes: a
  left pane at 50% width, and the right half split 50/50 top and bottom.
- All three panes are plain interactive shells rooted at the repo's checkout
  path — no commands are run in them.
- The left pane is the active pane when the client switches into the window.
- Windows that already exist are **not** touched: re-selecting an open repo
  still switches and changes nothing, including its pane arrangement.
- Applies to both creation paths — the first window of a newly created
  org/collection session, and a new window added to an existing session.
- Not a breaking change: no existing window, session, or naming behaviour moves.

## Capabilities

### New Capabilities

None — this extends the behaviour of an existing capability.

### Modified Capabilities

- `huphop-tmux-switcher`: the requirement "Selecting a repo creates or switches
  to its org session and repo window" gains the pane layout as part of what
  window creation produces, and pins that the already-open path stays inert.

## Impact

- `modules/USERS/pim/programs/huphop/default.nix` — the `hup-tmux-switch`
  wrapper script; the two window-creating branches gain split/select calls.
- No change to `hupConfig`, the `switch_command` template, the huphop input, or
  the `prefix + G` tmux binding.
- No new packages. tmux is already referenced by store path in the wrapper.
- Interacts with, but does not modify, the global `main-pane-width 80` and
  `pane-base-index 1` settings in `modules/USERS/pim/programs/tmux/default.nix`.
