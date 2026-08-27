## Context

GNOME/Nautilus is the DE on several hosts (zonnehoed, dapperehaan, lavendel, …),
launched via GDM → Wayland. Nautilus has no built-in right-click "copy plain path".
Two implementation altitudes were compared in exploration:

- **Python extension** (`chr314/nautilus-copy-path`): top-level menu item, but needs
  `nautilus-python` + wiring, and binds to Nautilus's introspection API — a breakage
  risk given the fleet is already on Nautilus 50 and tracks GNOME closely.
- **Nautilus script**: an executable in `~/.local/share/nautilus/scripts/` that
  Nautilus runs with `NAUTILUS_SCRIPT_SELECTED_FILE_PATHS` set. No API, no bindings.

The repo already provisions user scripts exactly this way
(`modules/USERS/annemarie/macos-catalina`: `home.file` with `executable = true`).

## Goals / Non-Goals

**Goals:**
- One right-click action to copy selected path(s) to the Wayland clipboard.
- Simplest possible, version-proof implementation using existing idioms.

**Non-Goals:**
- A top-level (non-submenu) context entry — accepted cost of the script approach.
- A configurable keyboard shortcut.
- X11 sessions (GNOME hosts run Wayland).
- Packaging the Python extension (kept only as a documented fallback).

## Decisions

### Nautilus script over Python extension

Chosen for zero API coupling (immune to GNOME/Nautilus bumps), ~5 lines of Nix, and
alignment with the existing `home.file`/`executable` pattern. The single trade-off is
placement under the **Scripts ▸** submenu instead of top-level, which was judged an
acceptable one-hover cost. The extension remains the fallback if a top-level item is
later required.

### `wl-copy` by store path (hermetic)

The GNOME session is Wayland and `wl-clipboard` is not installed on the GNOME hosts
(only under hyprland). Referencing `${pkgs.wl-clipboard}/bin/wl-copy` directly in the
script makes it work without touching `systemPackages` and without a PATH dependency.
`xclip` (used by tmux) is rejected — it does not drive the Wayland clipboard for
native apps.

### Plain paths, newline-joined

The script emits `$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS` verbatim (Nautilus already
provides absolute local paths, newline-separated for multi-select) — matching the
"plain path, not URI" intent.

### Home-manager module placement

A new `pim-gnome-*` home-manager module under `modules/USERS/pim/_gnome/`, imported
by the pim GNOME/desktop home profile so every GNOME host that gets pim's desktop
picks it up.

## Risks / Trade-offs

- **Submenu nesting** → Accepted; the whole decision hinges on it. Fallback is the
  extension.
- **Uncertain importer of `_gnome` home modules** → The existing `pim-gnome-*`
  modules' import site is not obvious from a grep; the correct profile/role to add
  the import to must be confirmed at apply time (see Open Questions).
- **Wayland-only** → If a GNOME host ever runs an X11 session, `wl-copy` won't reach
  that clipboard; out of scope, and easily extended later with an `xclip` fallback.
- **Script name with a space (`Copy Path`)** → Nautilus uses the filename as the menu
  label; a space is fine but must be quoted in Nix/paths.

## Open Questions

- Which home profile/role actually imports the `modules/USERS/pim/_gnome/*` modules
  today? Confirm and add the new module's import there (or wire it the same way the
  existing gnome desktop modules are pulled in).
- Menu label: `Copy Path` vs `Copy Path(s)` — cosmetic; default to `Copy Path`.
