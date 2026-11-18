# Design

## Context

See `proposal.md` for motivation and the two delta specs for the required behavior.
The tmux configuration is shared by every pim host through the `pim-tmux` home
module, which is imported by `role-pim-cli-minimal`. mipbar is imported only by
`role-pim-desktop`, so the server hosts have tmux but no bar and no ssh-agent.

The status bar is built by gpakosz's script, which sets `status-right` from
`tmux_conf_theme_status_right` and then runs `set -g status-right`. Modules append
to it with `set -ga status-right`. The current interval is 300 seconds.

## Goals / Non-Goals

**Goals:**

- One implementation of the key state, shared by mipbar and tmux, and one cached
  dirty count in tmux, all working on every host.
- The status segments must never block the bar for long and must survive a hung
  agent or a failing `drs`.
- Loading the key must work with only a terminal, so it works on servers reached
  over ssh.

**Non-Goals:**

- Sharing the dirty repo parser. mipbar needs the per-repo JSON, while tmux needs
  only a count, so the count comes from `drs --list` and mipbar keeps its parser.
- An unload action in tmux. Unloading is a desktop concern; the binding loads.
- Mouse bindings on the status segments. `prefix + U` is the entry point.
- Agent forwarding from the local machine. A forwarded agent cannot accept a key,
  so it would break the unlock binding.

## Decisions

### One shared `ssh-key-state` command

Put the four-state check in `packages/ssh-key-state/ssh-key-state.sh`, packaged as
`packages.ssh-key-state` in `flake.nix`. It prints one of `loaded`, `unloaded`,
`stale` or `noagent`, and accepts `--fingerprint` for the popover label.

The check is the logic that used to live in `packages/mipbar/widget/SshKey.tsx`:
fingerprint from `ssh-keygen -lf ~/.ssh/id_ed25519.pub`, `ssh-add -l` exit codes for
the no-agent state, and `timeout 4 ssh-add -T` for signability. It also works when
the public key file is missing: an empty fingerprint never matches, so the state is
unloaded rather than falsely loaded.

mipbar calls the command through `SSH_KEY_STATE`, a store path injected at bundle
time the same way as `ASKPASS`. The tmux status helper and the unlock helper call the
same command. This keeps the two surfaces from drifting instead of maintaining two
copies of the fingerprint and signability rules.

The three tmux helpers (`tmux-ssh-key`, `tmux-dirty-repos`, `ssh-key-unlock`) stay
`pkgs.writeShellScriptBin` values in `modules/USERS/pim/programs/tmux/default.nix`,
with their shell in `packages/tmux-status/`. The dirty count is not shared: tmux only
needs `drs --list | wc -l`, while mipbar parses `drs --json` for the per-repo list.

Alternative: keep a separate shell implementation in tmux. Rejected because the
fingerprint and signability rules are subtle enough that two copies would drift, and
the bar is the natural place to notice a regression.

### Status interval drops from 300 to 15 seconds

`status-interval` controls how often tmux re-runs `#()` commands. 300 seconds makes
an external `ssh-add` invisible for minutes. 15 seconds keeps the state useful while
the key check stays cheap. The dirty repo check is cached, so the lower interval
does not mean a scan every 15 seconds.

Alternative: leave 300 and force a redraw only after the unlock binding. Rejected
because keys also get loaded by an ordinary `ssh` through `AddKeysToAgent`, which
the bar would then miss.

### Cache files under `$XDG_RUNTIME_DIR/tmux-status`

The key state is cached for 5 seconds and the dirty count for 60 seconds. The key
cache keeps a hung sign check from running on every refresh. The dirty cache is what
makes a full `drs` scan acceptable on a 15 second interval. Writes go to a temporary
file and are renamed into place, so a refresh never reads a partial file. If a
refresh fails, the previous cache file stays and the segment keeps its last value.

Alternative: a systemd timer writing the cache. Rejected because the helpers then
need the timer to be deployed and started, and the status would still be as fresh as
the timer. The on-demand cache needs no extra unit.

### Unlock binding uses a tmux popup and a tty prompt

`prefix + U` opens `display-popup -E` running `ssh-key-unlock`. The script prints the
current state; when the key is not loaded it runs `ssh-add ~/.ssh/id_ed25519` with
`SSH_ASKPASS_REQUIRE=never`, so the prompt stays on the popup's terminal. After
`ssh-add` it runs `tmux refresh-client -S`. When the state is loaded it prints that
and waits for a keypress; on a missing agent or key file it prints the reason and
waits, so the popup does not flash closed.

Alternative: bind the popup directly to `ssh-add`. Rejected because it would ask for
the passphrase even when the key is already loaded, and a missing agent would close
the popup before the message could be read.

### A shared `pim-ssh` module owns the agent

Move the plain agent setup out of `pim-mipbar` into a new
`modules/USERS/pim/programs/ssh/default.nix` exporting `pim-ssh`:

- `services.ssh-agent.enable = true`, with the `ExecStartPre` that removes a stale
  socket.
- `systemd.user.sessionVariables.SSH_AUTH_SOCK = "%t/ssh-agent"`.
- `programs.ssh.settings."*".AddKeysToAgent = "yes"`.
- A Linux guard, because the Home Manager ssh-agent service is systemd-based.

`role-pim-cli-minimal` imports `pim-ssh`. The gcr masking, the askpass package and
the comment about not exporting askpass variables stay in `pim-mipbar`, where they
describe the desktop session.

Alternative: put the agent in `pim-git`. Rejected because the agent serves ssh and
gh as much as git, and the git module should stay about git.

## Risks / Trade-offs

- [A 15 second status interval costs more process starts on battery hosts] -> both
  checks are cached and the sign check is bounded; the scripts are plain shell.
- [`ssh-add` in a tmux popup may still pick the askpass path] -> the binding sets
  `SSH_ASKPASS_REQUIRE=never` explicitly, and the shared module never exports the
  askpass variables.
- [mipbar now depends on a store path for the key check] -> the path is injected at
  bundle time like `ASKPASS`, and the command is a small shell script with no
  runtime dependencies beyond `ssh-add`, `ssh-keygen` and `timeout`. A missing
  command leaves the widget in `noagent` rather than crashing it.
- [Moving the agent out of `pim-mipbar` changes desktop activation] -> the new
  module is imported by the CLI role, which every desktop host also imports, so the
  agent remains present. The gcr mask still applies on desktops through mipbar.
- [A remote host has no private key] -> the segment shows unloaded and the binding
  reports the missing file. Nothing tries to create or copy a key.

## Migration Plan

1. Add `pim-ssh` and import it from the CLI role.
2. Remove the agent settings from `pim-mipbar`, leaving the gcr mask and askpass.
3. Add the three helpers and append the two segments to `status-right`; set the
   interval to 15.
4. Deploy with `rme up_home` on the laptops and `rme up_machine` on the servers.
5. Rollback is a normal revert of the commit; the agent unit disappears with the
   module and the status appends with the tmux module.
