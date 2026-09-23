## Why

Fourteen custom tmux bindings live as loose `bind` lines in the `extraConfig`
blob of `modules/USERS/pim/programs/tmux/default.nix`. Nothing lists them, so the
only way to recall that `prefix + T` opens the `tj` picker is to read the Nix
file. tmux's own `prefix + ?` answers the question with a 283-line `list-keys`
dump in which the custom bindings are indistinguishable from the defaults, and
which cannot launch anything.

The bindings and the help are the same information written twice, which is the
usual reason a cheat sheet goes stale. One registry that emits both keeps them
in step by construction, and the same registry is the input
`mipnix-nzvf` needs for its continuously-updated presentation of the tmux popup
tooling.

## What Changes

- A Nix helper registers a binding as `{ key, desc, cmd }` and emits both the
  `bind` line and an entry in a help menu.
- The existing custom bindings move into the registry. Behaviour of each key is
  unchanged: same key, same command.
- `prefix + ?` is rebound from tmux's raw `list-keys` to a `display-menu` built
  from the registry, showing key, description and the action for each entry.
- The menu is navigable with the arrow keys, fires the highlighted entry on
  `Enter`, and closes on `Escape` without firing anything.
- Each entry's menu accelerator is its real binding key, so `S` inside the menu
  does what `prefix + S` does outside it.
- Entries are grouped: the popup tools first, the tmux utility bindings after a
  separator.
- Out of scope: dimming entries whose tool has no valid context. See design.md.

## Capabilities

### New Capabilities

- `tmux-bind-registry`: registering a custom tmux binding once and getting both
  the binding and its help-menu entry, plus the `prefix + ?` menu itself.

### Modified Capabilities

None. The individual tool bindings keep their current behaviour; only their
point of definition moves.

## Impact

- `modules/USERS/pim/programs/tmux/default.nix`: the registry helper, the
  bindings moved into it, and the generated `bind ?` line. The launcher scripts
  (`beans-tui-popup`, `nebula-ssh`, `drs-switch`) are untouched.
- `prefix + ?` stops being tmux's `list-keys`. That is the point of the change,
  and `tmux list-keys` remains available from a shell.
- No new packages. `display-menu` is built into tmux, so the menu adds no
  runtime dependency, unlike an fzf-based picker.
- Bindings defined outside this repo (tmux defaults, `tmux-sensible`, the
  gpakosz rewrites) stay out of the menu. The registry lists what this config
  declares, not what the server happens to have bound.
