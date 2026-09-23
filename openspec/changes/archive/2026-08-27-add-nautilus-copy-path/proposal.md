## Why

Nautilus (GNOME Files) has no convenient right-click "copy the file's path to the
clipboard" action — you have to reveal the path bar (`Ctrl+L`) and copy it by hand.
Third-party Python extensions (e.g. `chr314/nautilus-copy-path`) add a top-level
menu item, but they bind to Nautilus's introspection API and this fleet already
tracks GNOME aggressively (Nautilus 50), so an extension is a standing
maintenance/breakage risk on every GNOME bump. A Nautilus **script** delivers the
same capability with zero API coupling.

## What Changes

- Add a Nautilus script `Copy Path` at `~/.local/share/nautilus/scripts/` for `pim`
  on GNOME hosts, managed by home-manager (`home.file`, `executable = true`) — the
  same idiom already used for other user scripts.
- The script copies the selected item(s)' absolute path(s) to the clipboard from
  `$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS` (newline-joined for multi-select), piping to
  `wl-copy` referenced by Nix store path (hermetic; GNOME runs Wayland, and
  `wl-clipboard` is not otherwise installed on the GNOME hosts).
- No `nautilus-python`, no extension package, no overlay, no Nautilus-version
  coupling. The item appears under right-click → **Scripts ▸ Copy Path**.

## Capabilities

### New Capabilities
- `nautilus-copy-path`: A right-click Nautilus script that copies the selected
  file/folder path(s) to the Wayland clipboard, provisioned via home-manager for
  `pim` on GNOME hosts.

### Modified Capabilities
<!-- none -->

## Impact

- New home-manager module under `modules/USERS/pim/_gnome/` (a `pim-gnome-*`
  module), imported by the pim GNOME/desktop home profile.
- Depends on `pkgs.wl-clipboard` (referenced by store path only — not added to
  `systemPackages`).
- No change to system packages, Nautilus itself, or other DEs. X11-only sessions are
  out of scope (the GNOME hosts run Wayland).
- The `chr314/nautilus-copy-path` Python extension is the documented fallback if a
  top-level (non-submenu) menu item is later wanted, accepting the GNOME-bump risk.
