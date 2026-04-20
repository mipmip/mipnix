## Why

Adding a new NixOS host to the mipnix repo requires manually creating a directory under `modules/hosts/`, writing three boilerplate files (`configuration.nix`, `hardware.nix`, `networking.nix`), and copying + restructuring the installer-generated `hardware-configuration.nix` into the flake module pattern. This is error-prone and tedious — a `new_host` command in RUNME.sh would automate it, consistent with the existing `new_nebula_node` command pattern.

## What Changes

- Add `new_host` function to `RUNME.sh` that interactively scaffolds a new host directory
- Uses `gum` for interactive prompts (hostname, type suffix, architecture, optional nebula)
- Auto-wraps `/etc/nixos/hardware-configuration.nix` into the `flake.modules.nixos.<hostname>` pattern
- Generates minimal `configuration.nix` with `homeConfigurations`, `nixosConfigurations`, and a nixos module with base imports
- Generates `networking.nix` with hostname and firewall config
- Optionally calls the existing `new_nebula_node` function for nebula setup

## Capabilities

### New Capabilities
- `host-scaffolding`: Interactive creation of new NixOS host directories with templated configuration files

### Modified Capabilities

## Impact

- `RUNME.sh`: New function added
- Reads from `/etc/nixos/hardware-configuration.nix` (must be run on a machine with NixOS installed)
- Creates files under `modules/hosts/`
- Optionally triggers `new_nebula_node` flow
