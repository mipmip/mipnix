# terminal-shell-environment Specification

## Purpose
TBD - created by archiving change fix-terminal-gtk-env-leak. Update Purpose after archive.

## Requirements

### Requirement: Interactive shells do not inherit GTK app-wrapper variables
Ghostty is a wrapped GTK application: its nixpkgs binary wrapper exports
`GST_PLUGIN_SYSTEM_PATH_1_0`, `GI_TYPELIB_PATH` and `GDK_PIXBUF_MODULE_FILE`
into its own process so that *Ghostty* finds its GTK runtime. Those paths are
build-time artefacts of Ghostty's closure, not session settings, and the shell
Ghostty spawns inherits all of them (and passes them on to tmux and to every
program started from a pane).

The shell configuration SHALL unexport `GST_PLUGIN_SYSTEM_PATH_1_0`,
`GI_TYPELIB_PATH` and `GDK_PIXBUF_MODULE_FILE` at shell start, for both fish and
zsh, so that programs run from a terminal see the session's GLib/GTK defaults
instead of Ghostty's private ones.

The scrub SHALL run before any startup hook that invokes a GLib program.
Concretely: NixOS ships `share/fish/vendor_conf.d/flatpak.fish`, which runs
`flatpak --installations` on every fish start, and fish sources `conf.d` files
(sorted by filename) *before* `config.fish`. A scrub placed in
`interactiveShellInit` therefore runs too late — verified: with a polluted
`GIO_EXTRA_MODULES`, `fish -i -c 'echo MARKER'` prints the module-load errors
before `MARKER`. fish SHALL therefore install the scrub as an early-sorting
`conf.d` file, and zsh SHALL install it in `.zshenv` rather than `.zshrc`.

#### Scenario: Fresh terminal has no GTK wrapper leakage
- **WHEN** a new Ghostty window is opened and an interactive fish or zsh shell starts
- **THEN** `GST_PLUGIN_SYSTEM_PATH_1_0`, `GI_TYPELIB_PATH` and `GDK_PIXBUF_MODULE_FILE`
  SHALL be unset in that shell's environment

#### Scenario: Scrub precedes the flatpak fish hook
- **WHEN** fish starts with a `GIO_EXTRA_MODULES` containing a GStreamer plugin
  directory, so that `flatpak --installations` in `vendor_conf.d/flatpak.fish` would
  otherwise scan it
- **THEN** the scrub SHALL already have run, and no `Failed to load module` line
  SHALL be printed

#### Scenario: tmux panes inherit the cleaned environment
- **WHEN** a tmux server is started from such a shell and a new pane is opened
- **THEN** the pane's shell SHALL also have those three variables unset

#### Scenario: GTK applications launched from the terminal still work
- **WHEN** a wrapped GTK application (e.g. `firefox`, `walker`, `ghostty`) is launched
  from a terminal whose environment has been cleaned
- **THEN** it SHALL still find its own GTK runtime, because its own binary wrapper
  re-exports the variables it needs

### Requirement: GIO module search path excludes GStreamer plugin directories
`GIO_EXTRA_MODULES` is a list of directories that GLib `dlopen`s and probes for
the `g_io_module_load` symbol. GStreamer plugin directories (`.../lib/gstreamer-1.0`)
contain shared objects that do not export that symbol, so if such a directory ends
up on `GIO_EXTRA_MODULES` every GLib/GIO program prints one
`'g_io_module_load': <path>: undefined symbol: g_io_module_load` and one
`Failed to load module: <path>` line per plugin — dozens of lines of noise on
terminal start.

The shell configuration SHALL remove any path segment ending in
`/gstreamer-1.0` from `GIO_EXTRA_MODULES` at shell start, leaving the
remaining (legitimate) entries and their order intact, and SHALL leave the variable
unset if it was unset.

#### Scenario: Polluted GIO_EXTRA_MODULES is sanitised
- **WHEN** a shell starts with a `GIO_EXTRA_MODULES` that contains one or
  more `.../lib/gstreamer-1.0` entries
- **THEN** those entries SHALL be dropped and running a GIO program (for example
  `gio info /`) SHALL produce no `Failed to load module` output

#### Scenario: Clean GIO_EXTRA_MODULES is preserved
- **WHEN** a shell starts with `GIO_EXTRA_MODULES` containing only
  gvfs / glib-networking / dconf module directories
- **THEN** the value SHALL be unchanged

#### Scenario: GIO_EXTRA_MODULES unset
- **WHEN** a shell starts with `GIO_EXTRA_MODULES` unset
- **THEN** the shell SHALL NOT export it

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
