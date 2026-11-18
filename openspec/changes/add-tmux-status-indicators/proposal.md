# Proposal

## Why

mipbar shows the ssh key lock state and the dirty repo count, but those indicators
are missing on hosts that run only the tmux profile. On a remote host reached over
nebula, the tmux status bar is the only always-visible surface. Without the lock
state the user has to run `ssh-add -l` by hand, and without a way to load the key
on that host, `gh` and git over SSH fail until the user remembers the command.

## What Changes

- Add an ssh key segment to the tmux status bar, using the same four states as
  mipbar: loaded, unloaded, stale and no agent.
- Add a `prefix + U` binding that opens a popup and loads the key with a normal tty
  passphrase prompt, so it works on hosts without a graphical askpass.
- Add a dirty repo segment to the tmux status bar showing the count from
  `drs --list`.
- Run a plain OpenSSH ssh-agent on every pim host, not only on hosts with mipbar,
  and point `SSH_AUTH_SOCK` at it. Without a local agent, `ssh-add` on a server
  cannot load anything and the unlock binding has no target.
- Lower the tmux status refresh interval so the two segments reflect the current
  state without a manual redraw.

## Capabilities

### New Capabilities

- `tmux-status-indicators`: the ssh key state segment, the dirty repo count
  segment, and the key unlock binding in tmux.
- `shared-ssh-agent`: a plain OpenSSH ssh-agent and `AddKeysToAgent` on every pim
  host, including CLI-only hosts.

### Modified Capabilities

(none)

## Impact

- `modules/USERS/pim/programs/tmux/default.nix`: status segments, helper scripts,
  status interval, and the `K` binding through the hotkey registry.
- A new shared ssh-agent module, imported by the CLI role. The agent setup moves
  out of `modules/USERS/pim/programs/mipbar/default.nix`; the desktop-only gcr
  masking and askpass package stay there.
- A shared `ssh-key-state` command, packaged from
  `packages/ssh-key-state/`, used by both `packages/mipbar/widget/SshKey.tsx` and
  the tmux helper. The dirty count uses the same `drs` output as
  `packages/mipbar/widget/DirtyRepos.tsx` but only needs `drs --list`. Both work on
  remote hosts, where mipbar is not installed.
- Rollout: `rme up_home` on the desktop hosts and `rme up_machine` on the servers.
