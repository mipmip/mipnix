## Why

Annemarie has a macOS Catalina QEMU VM on lavendel that requires running two scripts in sequence from a specific working directory. Currently this requires opening a terminal and running commands manually. A desktop launcher with a macOS icon would make this a single-click operation.

## What Changes

- Create a new home-manager module `modules/USERS/annemarie/macos-catalina/` with:
  - A `.desktop` entry for "macOS Catalina" with a macOS icon, initially with `terminal = true` for debugging
  - A wrapper script managed via `home.file` that `cd`s to `/home/annemarie` and runs `setup-network.sh` then `macos-catalina.sh`
  - A macOS icon file deployed to `~/.local/share/icons/`
- Fix bug: `annemarie@lavendel` home-manager config is missing `username` and `homedir` parameters (defaults to pim's values)
- Import the new module in annemarie's home-manager config

## Capabilities

### New Capabilities
- `macos-catalina-launcher`: Desktop application entry and wrapper script for launching Annemarie's macOS Catalina QEMU VM

### Modified Capabilities

## Impact

- `modules/USERS/annemarie/annemarie-core.nix`: Fix `annemarie@lavendel` makeHomeConf params, add import for new module
- New directory: `modules/USERS/annemarie/macos-catalina/`
- Deploys files to annemarie's home on lavendel: `~/.local/share/applications/`, `~/.local/share/icons/`, wrapper script
