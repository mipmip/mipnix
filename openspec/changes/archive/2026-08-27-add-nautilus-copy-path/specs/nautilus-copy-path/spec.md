## ADDED Requirements

### Requirement: Right-click copies the selected path(s)

Nautilus SHALL offer a `Copy Path` script (under right-click → Scripts) that places
the absolute filesystem path of the selected item(s) on the clipboard. For a
multi-item selection the paths SHALL be joined one per line. The copied value SHALL
be the plain path (e.g. `/home/pim/x`), not a `file://` URI.

#### Scenario: Single item

- **WHEN** the user selects one file or folder and runs Scripts → Copy Path
- **THEN** that item's absolute path is placed on the clipboard and a subsequent
  paste yields exactly that path

#### Scenario: Multiple items

- **WHEN** the user selects several items and runs Copy Path
- **THEN** the clipboard contains their absolute paths, one per line

#### Scenario: Wayland clipboard

- **WHEN** the script runs in the GNOME Wayland session
- **THEN** it copies via `wl-copy` (resolved by Nix store path) so the value is
  available to other Wayland applications

### Requirement: Declarative provisioning, no extension

The script SHALL be provisioned declaratively by home-manager for `pim` on GNOME
hosts as an executable file under `~/.local/share/nautilus/scripts/`, and SHALL NOT
rely on `nautilus-python` or any Nautilus extension API.

#### Scenario: Script is present and executable after switch

- **WHEN** the GNOME host is rebuilt / the home profile is switched
- **THEN** `~/.local/share/nautilus/scripts/Copy Path` exists and is executable, and
  Nautilus lists it under its Scripts submenu

#### Scenario: Survives a Nautilus/GNOME upgrade

- **WHEN** nixpkgs bumps Nautilus or GNOME
- **THEN** the script SHALL continue to work unchanged, as it uses no Nautilus API —
  only the `NAUTILUS_SCRIPT_SELECTED_FILE_PATHS` environment contract
