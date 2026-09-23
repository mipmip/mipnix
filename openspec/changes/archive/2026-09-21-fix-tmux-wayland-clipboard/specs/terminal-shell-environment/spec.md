## ADDED Requirements

### Requirement: tmux carries the Wayland display into its panes and popups

tmux's `update-environment` SHALL include `WAYLAND_DISPLAY`, so that a client
attaching from a Hyprland terminal refreshes the session environment and every
pane, window and popup created afterwards can reach the compositor.

Without it, the tmux server keeps whatever environment it was started with. On
doornappel that environment has no `WAYLAND_DISPLAY` at all, while the
compositor's socket is `/run/user/1000/wayland-1`. Programs in a pane therefore
either fall back to the default `wayland-0`, which does not exist, or conclude
that no Wayland session is present.

This is what makes clipboard tools report themselves as missing when they are
installed. The Go `atotto/clipboard` library, which `beans` uses, only considers
`wl-copy`/`wl-paste` when `WAYLAND_DISPLAY` is set; otherwise it falls through to
`xclip` and `xsel`, and when those are absent it reports "No clipboard utilities
available", naming wl-clipboard as one of the things to install even though
wl-clipboard is installed.

Installing `xclip` or `xsel` to satisfy that fallback SHALL NOT be the fix: they
are X11 tools on a Wayland session, and they would paper over a session
environment that is wrong for every other Wayland-aware program too.

#### Scenario: A pane can reach the compositor

- **WHEN** a tmux client is attached from a Hyprland terminal and a new pane is
  created
- **THEN** `WAYLAND_DISPLAY` SHALL be set in that pane
- **AND** `wl-copy` SHALL connect to the compositor instead of failing with
  "Failed to connect to a Wayland server"

#### Scenario: Yank from a TUI in a popup

- **WHEN** the beans TUI is opened with `prefix + B` and its Yank action is used
- **THEN** the text SHALL be placed on the Wayland clipboard
- **AND** no "No clipboard utilities available" error SHALL be shown

#### Scenario: Panes that predate the attach

- **WHEN** a pane was created before a client attached with the variable present
- **THEN** that pane MAY still carry the old environment, since
  `update-environment` applies to the session at attach time and not to running
  processes
- **AND** a new pane, window or popup SHALL have the current value

#### Scenario: No Wayland session

- **WHEN** a client attaches from a context with no `WAYLAND_DISPLAY`, such as an
  ssh session
- **THEN** the variable SHALL be removed from the session environment rather than
  left at a stale value

### Requirement: tmux copy-mode yank uses the Wayland clipboard

The `copy-mode-vi` yank binding SHALL pipe the selection to
`${pkgs.wl-clipboard}/bin/wl-copy`, referenced by Nix store path, replacing the
current `xclip -in -selection clipboard`.

`xclip` is not installed on any host in this configuration, so the binding as it
stands fails silently on every yank. Referencing wl-copy by store path follows
the pattern already used by `nautilus-copy-path`, whose own comment states the
reason: it works without wl-clipboard being in `systemPackages` and without a
PATH dependency.

#### Scenario: Yanking a selection in copy mode

- **WHEN** the user selects text in copy mode and presses `y`
- **THEN** the selection SHALL be placed on the Wayland clipboard
- **AND** the selection SHALL be pasteable into a Wayland application

#### Scenario: The binding names a program that exists

- **WHEN** the generated tmux configuration is inspected
- **THEN** the yank binding SHALL reference an existing Nix store path
- **AND** SHALL NOT reference `xclip`
