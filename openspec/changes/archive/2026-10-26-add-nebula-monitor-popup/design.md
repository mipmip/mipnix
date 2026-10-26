## Context

See proposal.md for motivation. What the approach has to work within:

- tmux 3.6a. `display-popup -b` and `-c target-client` are available.
- A popup attaches to a session. It cannot host a pane that already lives
  elsewhere, and it cannot open a second popup from inside itself. Both facts
  are already established by `tmux-float-pane` and `tmux-bind-registry`.
- Custom bindings come from `flake.hotkeys` filtered to the tmux target, in
  `binds.nix`. Each entry emits a `bind` line, a `prefix + ?` row and a
  cheatsheet line.
- Launcher scripts are `writeShellScriptBin` in the tmux module's `let` block,
  referenced by bare name from the binding: `nebula-ssh`, `drs-switch`,
  `tmux-float`.
- `float.sh` already runs `display-popup` from inside a `run-shell -b` script,
  passing `-c "#{client_tty}"` read at the start. That pattern is proven here
  and is reused rather than reinvented.
- `flake.nebulaNodes` is a merged `name -> ip` registry contributed per host.
  `self.lib.nebulaHosts` renders it as `"<name> <ip>"` lines for the ssh picker.
- `_advanced_smugs.nix` is imported as
  `import ./_advanced_smugs.nix { inherit pkgs; inherit makeBanner; }`, so it
  has no access to `inputs` today.
- `M` is unbound. Used keys are `S G T B D H R P A F + - s Tab ; b O`.

## Goals / Non-Goals

**Goals:**

- Opening costs nothing: no process start, no fetch, no lost history.
- The two-pane layout is stable no matter what the user does to the tools
  inside it.
- One host list for the popup, the smug session and the ssh picker.

**Non-Goals:**

- A third pane. `btop` and `claude-monitor` stay in the smug `monitoring`
  session; this popup answers one question about the mesh.
- Width control. The popup is opened at one size; `tmux-float`'s `+` and `-`
  keys belong to the float and stay there.
- Replacing the smug `monitoring` session. It keeps its CoreVitals window and
  stays the place to sit and watch; the popup is the place to glance.
- Acting on what the monitor shows (restart, alert, notify).

## Decisions

### A persistent background session, not a popup-scoped one

`tmux-float` kills its hidden session on every close, because the pane it holds
belongs somewhere else. Here the opposite is wanted: the value of the popup is
that `nping` has been pinging and `updo` has been sampling while you were not
looking. A tool restarted on each open shows an empty table and a 100% uptime
figure computed over four seconds, which is worse than useless because it looks
like an answer.

So the session is created on first open and left running. Closing the popup
detaches its client:

```
  first open              closed                  reopened
  +-----------+           +-----------+           +-----------+
  |nping|updo |  detach   |nping|updo |  attach   |nping|updo |
  | ... | ... |  ------>  | ...   ... |  ------>  | ....| ....|
  +-----------+  (keeps   | running   |           +-----------+
   popup         running) +-----------+            popup
```

Rejected: kill on close, as the float does. It makes the feature pointless.

Rejected: a systemd user service holding the tools. It would need its own tmux
server or its own pty handling, and the session is already the right container.

### The toggle is a conditional binding, not a script-side check

Because the session outlives the popup, "does the session exist" cannot tell
open from close. What distinguishes them is which session the pressing client is
attached to. That is exactly the test the float's `+` and `-` keys already use:

```
  bind M if -F '#{==:#{session_name},_nbmon}' \
            'detach-client' \
            "run-shell -b 'nebula-monitor open'"
```

Inside the popup the key arrives from the popup's own client, whose session is
`_nbmon`, so it detaches and the popup closes. Everywhere else it opens.

Rejected: a `toggle` subcommand in the script that reads the session name
itself. `run-shell -b` detaches from the client it was fired from, and the
condition has to be evaluated against the pressing client, so the test belongs
in the bind where tmux already has that context.

### `remain-on-exit on` plus `respawn-pane`, so the layout cannot collapse

If `updo` exits, tmux's default is to destroy the pane. The split collapses to
one pane and the popup silently stops being a two-tool view, with nothing to say
why. Reopening would then have to guess whether to split again.

`set -t _nbmon remain-on-exit on` keeps the dead pane in place, holding its slot
and its last output. On each open, the launcher respawns any pane whose
`#{pane_dead}` is set, with the command that pane is supposed to run. A pane
that is alive is left strictly alone, so a long-running `nping` is never
restarted as a side effect of the other tool having quit.

Pane identity is positional: pane 1 is `nping`, pane 2 is `updo`. With
`remain-on-exit` the panes never disappear, so the indices are stable for the
life of the session, and a per-pane user option would be a second thing to keep
in sync for nothing.

Rejected: `respawn-pane -k` on every open. It kills the running process, which
loses the history the whole design exists to keep.

Rejected: checking `#{pane_current_command}` against the tool name. It reports
the foreground process, which is right for a running tool and says nothing
useful about a pane running a shell left behind by some other path.

### The popup is sized for two tables

`nping -v table` and `updo` each render a table of hosts. The picker popups in
this configuration are 60% to 90% wide, which would leave each tool under half
of that. The popup opens at 98% by 85%: nearly the whole terminal, with enough
margin that it still reads as something in front rather than a window swap.

The split is `even-horizontal`, which gives a vertical divider and two equal
columns. tmux's horizontal and vertical naming is the usual trap here: the
wanted result is panes beside each other, which is `split-window -h`.

### `nebulaHostNames` beside `nebulaHosts`

`nping` takes bare host names; the ssh picker needs `name ip` pairs. Rather than
making the launcher strip the IP back off, `modules/nix/helpers.nix` gains

```
  nebulaHostNames = lib.attrNames self.nebulaNodes;
```

next to the existing `nebulaHosts`. Both are one `lib` call over the same
registry, both read literal strings only, and neither evaluates
`nixosConfigurations`.

### Packaging `nping` and `updo` as flake inputs

Both are invoked today as `nix run github:mipmip/...` inside the smug session.
For a session you start once a day that is tolerable; for a popup bound to a key
it is not, and it makes the monitor depend on the network being up, which is the
condition it exists to report on.

So both become flake inputs alongside `huphop`, `beandex` and the rest, with
`inputs.nixpkgs.follows = "nixpkgs"` where upstream allows it, and are
referenced by store path from the launcher and from the smug session.

### The smug session reads the same two things

`_advanced_smugs.nix` is imported with `{ inherit pkgs; inherit makeBanner; }`,
so it cannot see `inputs`. The import gains `inherit inputs;` and the two
monitoring commands become store-path invocations over the derived host list.
That removes the only other copy of the host list and the only other `nix run`.

The alternative, passing the two finished command strings in from
`default.nix`, keeps the smug file ignorant of `inputs` but puts two commands in
a file that holds no other commands. Passing `inputs` is the smaller change and
matches how every other module in this tree reaches the flake.

## Risks / Trade-offs

- **The session is visible in `prefix + s` and in `choose-tree`.** → Accepted.
  It is named `_nbmon`, with the leading underscore that `_float` already uses
  for a session that is not a workspace. Hiding it is not possible without
  hiding it from the popup too.
- **Two tools pinging forever, on a laptop, on battery.** → `nping -i 3` is one
  ICMP round per host every three seconds and `updo` samples at the interval in
  its config. Both are small, but this is the first thing in the configuration
  that runs indefinitely without being looked at. If it shows up in power
  measurements, the fix is to kill the session on close and accept the cold
  start, which is a one-line change to the toggle.
- **The popup cannot be opened from the `prefix + ?` menu while it is open.**
  → True of every popup entry already, and the menu is a `display-menu` for
  exactly that reason.
- **`nping` watching laptops that are usually off.** → They will sit in the
  table as unreachable. That is the registry's answer to "which nodes exist",
  and a second list of "nodes worth watching" is the duplication this change
  removes. If the noise becomes a problem the registry is the place to mark it.
- **Two new flake inputs.** → Both are already depended on, through a less
  reliable mechanism. The lock grows by two entries.

## Open Questions

- Whether the popup should eventually also show `nebula-cert` expiry, which is
  the other thing that silently breaks the mesh. It would be a third pane or a
  footer line, and it changes nothing in the specs or the task breakdown.
