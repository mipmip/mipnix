## Context

The picker opens a local window in the `nebula-prive` session with `ssh
pim@<ip>`, so the remote login shell runs inside the outer tmux. Starting tmux
there nests two servers that both use `C-a`; the outer one consumes the prefix
key and the inner one never sees it. `unbind C-a` in the shared config removes
the `send-prefix` binding, so `C-a C-a` does not pass it through either.

In tmux 3.7b, `prefix` and `prefix2` are session options and a new value applies
to existing sessions that have no local override. The configuration file is
read when a server starts, not when a client attaches. Remote hosts receive the
same home-manager tmux configuration through a deploy.

## Goals / Non-Goals

**Goals:**

- Give the tmux server that is started from a popup shell a prefix the outer
  server does not consume.
- Keep local tmux, direct ssh sessions, and console attaches on `C-a`.
- Require no per-host tmux configuration and no change to the picker's host
  list.

**Non-Goals:**

- Making the outer tmux forward `C-a`, or changing its prefix.
- Making an already-running remote server adopt the second prefix.
- Changing how the picker creates or reuses windows.

## Decisions

**Carry the marker in the environment.** The picker starts the remote login
shell with `NEBULA_TMUX=1`, using `ssh -t` so a TTY exists. A shell started from
the popup passes the variable to anything it launches, including the tmux
server, which needs no other signal. Alternatives considered: a per-host tmux
configuration (duplicates the shared config and needs host-specific files) and
an ssh `SetEnv` with `AcceptEnv` (needs sshd configuration on every host).

**Set `prefix2` instead of replacing `prefix`.** `C-s` becomes a second prefix
and `C-a` remains primary. When nested, the outer server takes `C-a` anyway, so
`C-s` is the only one that reaches the inner server; at the console, `C-a`
still works. Replacing the prefix was rejected because the same server can be
attached from the console, where the change would be surprising.

**Decide at server start, from the tmux configuration.** The shared config gets
`if-shell '[ -n "$NEBULA_TMUX" ]' 'set -g prefix2 C-s ; set -g @prefix_extra C-s'`.
This covers every way tmux starts from the popup shell, including `t`, `smug`,
and a bare `tmux`. Putting the override in the `t` alias was rejected because it
would handle only that alias, and because setting an option on a running server
has to deal with the server already existing.

**Show the second prefix in the status bar.** Gpakosz's status-right renders
`#{prefix_key}` from `show-options -g prefix`, so it would keep showing only the
primary prefix. tmux exposes user options to formats but not the value of
`prefix2`, so the config sets `@prefix_extra C-s` next to `prefix2 C-s`, and the
status-right appends `#{?@prefix_extra, #{@prefix_extra},}`. Repeating the key in
one `if-shell` keeps the two in sync. The alternative, a shell command that
reads both options, needs nested quoting inside `#()` and was rejected.
The same option selects the leading marker, `#{?@prefix_extra,👻,🤠}`, so a
popup session is recognizable at a glance while local servers keep 🤠.

**Keep the shell in the popup.** The ssh command starts `"$SHELL" -l` rather
than attaching tmux directly. The popup stays a shell, so the user starts tmux
with the usual alias and keeps the shell's own environment and startup files.

**Do not bind `C-s send-prefix`.** Sending a literal `C-s` into a pane reaches
the shell as XOFF and freezes its output. The second prefix stays input-only.

## Risks / Trade-offs

- A remote server that is already running ignores the new configuration until
  it restarts. Acceptable; the alternative is mutating a live server from the
  alias, which was rejected above.
- `C-s` is XOFF at a plain shell. Before tmux starts, pressing it still freezes
  output until `C-q`; this is unchanged terminal behavior, not introduced by
  the prefix.
- `C-a C-a` still does nothing because of `unbind C-a`. This change does not
  restore forwarding; it makes the inner server reachable through `C-s`
  instead.
- The ssh command carries nested quoting for `$SHELL`. The expansion is
  deferred to the remote side; the generated command was checked for that.

## Migration Plan

1. Deploy the shared home-manager configuration to the hosts that will be
   tested.
2. Restart each host's tmux server, or accept that the next fresh server picks
   up the prefix.
3. To roll back, revert the commit and restart the servers; a live server can
   also run `tmux set -g prefix2 None`.

## Open Questions

None.
