## Why

tmux's zoom fills the window edge to edge. That is right when the pane is the
only thing that matters and wrong when it is one thing among several: a log you
want to read properly, a diff you want wider, a REPL you want in front of you
for a minute. A centred pane with margins reads better and makes it obvious
that the pane is temporarily in front rather than the whole window.

A popup cannot host an existing pane, so the pane has to move somewhere the
popup can attach to and come back afterwards.

## What Changes

- Add a toggle that moves the current pane into a hidden session, shows that
  session in a centred popup, and blanks the pane's old slot with a placeholder
  until the toggle brings it back.
- Restore the window layout exactly. Verified on a spike: the `window_layout`
  string before floating and after restoring are byte-identical, checksum
  included, and the process inside the pane keeps running throughout.
- Bind `+` and `-` to widen and narrow the popup in steps of 10, clamped to
  20-100, active only inside the float and falling through to their normal
  bindings everywhere else.
- Bind the toggle to `F`. `f` is tmux's `find-window -Z`, which is worth
  keeping, and `F` is unbound.
- Add `menu = false` to the hotkey registry, so a binding can be registered and
  documented without appearing in the `prefix + ?` menu. `+` and `-` mean
  nothing outside the float and do not belong in a flat list of every binding.
- Reject at build time a registered key that would disable its own menu row.
  tmux renders a menu item whose name begins with `-` as dim and unselectable,
  and the menu name starts with the key, so registering `-` for the menu would
  silently produce a dead row.

## Capabilities

### New Capabilities

- `tmux-float-pane`: the toggle, what it guarantees about restoring the layout,
  the width control, and what happens when the float is left in an unusual
  state.

### Modified Capabilities

- `hotkey-registry`: an entry can be bound and documented while being kept out
  of a target's menu. Nothing about existing entries changes; they stay in the
  menu as before.
- `tmux-bind-registry`: the menu currently shows every registered binding. It
  now shows every registered binding except those marked out, and a key that
  cannot be rendered as a menu row fails the build rather than appearing dead.

## Impact

- `modules/USERS/pim/programs/tmux/default.nix`: three `writeShellScriptBin`
  launchers beside `beans-tui-popup`, `nebula-ssh` and `drs-switch`
- `modules/USERS/pim/programs/tmux/binds.nix`: three entries
- `modules/hotkeys/option.nix`: the `menu` field
- `lib/hotkeys.nix`: the menu filter and the new build-time check

Constraints:

- tmux 3.6a is in use and `display-popup -b` needs 3.3, so the floor is met.
- One float at a time for the whole server. With a single attached client, which
  is the case here, you can only be looking at one session anyway.
- `bind -r` repeat does not survive the popup being reopened on resize. Accepted:
  each width step is a separate `prefix +`.
