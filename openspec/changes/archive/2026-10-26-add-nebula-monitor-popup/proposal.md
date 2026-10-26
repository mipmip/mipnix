## Why

Checking whether the nebula hosts are up means switching to the `monitoring`
smug session, which lives in its own window and takes the screen. The two tools
that answer the question, `nping` for mesh reachability and `updo` for the HTTP
endpoints, are already configured there, but reaching them costs a context
switch away from whatever is in front of you.

A popup is the right shape for a glance: it opens over the current pane,
answers the question, and closes without disturbing the layout. The existing
popup bindings (`prefix + H`, `prefix + B`, `prefix + F`) already establish that
pattern, and a popup can hold more than one pane, so both tools fit side by
side.

## What Changes

- Add a `prefix + M` popup that shows `nping` and `updo` side by side in one
  window.
- Bind `Escape` to close the popup, without the prefix, leaving both tools
  running. Outside the popup the key keeps its ordinary meaning.
- Back the popup with a hidden tmux session that survives the popup closing, so
  the ping history and the uptime samples keep accumulating between glances
  rather than restarting on every open.
- Derive nping's host list from `flake.nebulaNodes`, the same registry that
  feeds the `prefix + H` ssh picker, instead of the list hardcoded in
  `_advanced_smugs.nix`.
- Add `nping` and `updo` as flake inputs and reference them by store path, so
  the popup opens without a `nix run` fetch.
- Point the smug `monitoring` session's two panes at the same packaged binaries
  and the same derived host list, so the popup and the session cannot disagree
  about which hosts are monitored.

## Capabilities

### New Capabilities

- `nebula-monitor-popup`: the binding, the two-pane layout, what the backing
  session guarantees about persistence between opens, where the host list comes
  from, and what happens when the popup is too narrow for two panes.

### Modified Capabilities

- `hotkey-registry`: a tmux entry's kind now decides which key table binds it.
  A `prefixed` entry binds after the prefix, as every tmux entry does today; a
  `chord` binds in the root table, so its key acts on its own. No field is
  added, because the kinds already carry that distinction. A tmux chord
  carrying a modifier fails the build, since the registry holds no tmux
  spelling for one.
- `tmux-bind-registry`: the emitter writes `bind -n` for a chord and `bind` for
  a prefixed entry. Every existing entry is prefixed and is emitted exactly as
  before.

## Impact

- `flake.nix`: two inputs, `nping` and `updo`
- `modules/USERS/pim/programs/tmux/default.nix`: one `writeShellScriptBin`
  launcher beside `nebula-ssh` and `tmux-float`
- `modules/USERS/pim/programs/tmux/binds.nix`: one entry in the `tools` group,
  one chord in the `tmux` group for the close key
- `lib/hotkeys.nix`: the tmux bind emitter, and the check on a tmux chord's
  modifiers
- `modules/nix/helpers.nix`: a `nebulaHostNames` helper beside `nebulaHosts`
- `modules/USERS/pim/programs/smug_n_skull/_advanced_smugs.nix`: the two
  monitoring commands lose their `nix run` prefix and their hardcoded host list
- `modules/USERS/pim/programs/updo/default.nix`: unchanged; the popup reads the
  same `~/.config/updo/config.toml`

Constraints:

- tmux 3.6a, so `display-popup -b` and `-c target-client` are available.
- `nping -v table` and `updo` both want width. Two panes in a popup narrower
  than the terminal means each gets less than half a screen.
