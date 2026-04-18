## Context

Annemarie uses a macOS Catalina QEMU VM on lavendel via two scripts at `/home/annemarie/macos-catalina/`. The scripts must run sequentially (setup-network.sh first, then macos-catalina.sh) with CWD set to `/home/annemarie`. Neither script requires sudo. Lavendel runs GNOME as its desktop environment.

Pim's `modules/USERS/pim/programs/freedesktop/default.nix` demonstrates the existing pattern for desktop entries and icon deployment via home-manager.

There's also a bug: `annemarie@lavendel` in `annemarie-core.nix` is missing `username` and `homedir` params, causing it to default to pim's values.

## Goals / Non-Goals

**Goals:**
- Single-click macOS Catalina launch from GNOME app grid with a macOS icon
- Wrapper script owned by mipnix (managed via `home.file`)
- `terminal = true` initially for debugging; flip to `false` once validated

**Non-Goals:**
- Managing the QEMU scripts themselves (they live outside mipnix at `/home/annemarie/macos-catalina/`)
- Making this available on other hosts or for other users

## Decisions

### 1. Module location: `modules/USERS/annemarie/macos-catalina/`

New directory with `default.nix` containing the desktop entry, wrapper script, and icon deployment. Follows the pattern of `modules/USERS/pim/programs/freedesktop/`.

**Alternative**: Put it directly in `annemarie-core.nix`. Rejected because the existing pattern uses dedicated modules per concern.

### 2. Wrapper script via `home.file` to a bin directory

Deploy a wrapper script to `~/.local/bin/start-macos-catalina.sh` via `home.file`. The script:
1. `cd /home/annemarie`
2. Runs `./macos-catalina/setup-network.sh`
3. `exec`s `./macos-catalina/macos-catalina.sh`

Using `exec` so the terminal (while `terminal = true`) stays attached to the QEMU process.

### 3. Icon as PNG via `home.file`

Deploy a macOS Finder/Apple logo icon to `~/.local/share/icons/macos-catalina.png`. The `.desktop` entry references it by name (`macos-catalina`). A PNG file ships alongside the nix module.

### 4. Desktop entry with `terminal = true` initially

Start with `terminal = true` so Annemarie (and Pim for debugging) can see script output. Once validated, flip to `false` for a cleaner experience.

### 5. Fix `annemarie@lavendel` makeHomeConf

Add `username = "annemarie"` and `homedir = "/home/annemarie"` to match the passieflora entry. Without this fix, the new module wouldn't deploy to the right home directory anyway.

### 6. Import path

The new module exports `flake.modules.homeManager.annemarie-macos-catalina`. This gets imported in the `annemarie` home-manager module's `imports` list in `annemarie-core.nix`.

## Risks / Trade-offs

- **[Scripts not managed by mipnix]** → If the scripts move or change, the wrapper breaks. Acceptable since this is Annemarie's personal setup and the scripts are unlikely to move.
- **[Icon licensing]** → The Apple logo is trademarked. For personal use on a single machine this is fine. Use a generic/stylized macOS icon.
