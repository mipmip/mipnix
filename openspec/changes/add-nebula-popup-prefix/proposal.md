## Why

The `prefix + H` picker opens a shell on a nebula host inside the local tmux,
and starting tmux in that shell puts a second tmux inside the first. Both
servers then want `C-a` as prefix, but the outer server consumes it before the
inner one sees it. The inner server is therefore unreachable, and no host-side
configuration can fix that while the outer prefix stays `C-a`.

The popup is the only place where this nesting happens on purpose, so the
override belongs to that connection rather than to every tmux on every host.

## What Changes

- Mark the shell that the picker opens with `NEBULA_TMUX=1` and start it as a
  login shell, so the marker reaches the remote tmux server.
- In the shared tmux config, set `prefix2 C-s` when the server starts with that
  marker. `C-a` stays the primary prefix, so an ordinary attach at the console
  and a direct ssh session keep working as before.
- Leave local tmux and hosts reached outside the picker untouched: the marker
  exists only in the popup's shell.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `nebula-ssh-tmux-picker`: the per-host window runs an ssh command that
  allocates a TTY and starts a login shell with `NEBULA_TMUX=1`; a tmux server
  started from that shell uses `C-s` as a second prefix.

## Impact

- `modules/USERS/pim/programs/tmux/default.nix`: the `nebula-ssh` window
  command and one conditional in the tmux `extraConfig`.
- The tmux configuration is shared with the remote hosts, so the change
  requires a deploy there. Remote servers started before that deploy keep their
  current prefix until they restart.
- No change to `binds.nix`, the hotkey registry, or the bindings menu; `C-s` is
  a prefix, not a binding.
