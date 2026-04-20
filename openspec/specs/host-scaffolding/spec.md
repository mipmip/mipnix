# host-scaffolding Specification

## Purpose
Provides the `new_host` command in RUNME.sh for interactively creating new NixOS host configurations using the roles pattern.

## Requirements
### Requirement: Interactive host creation command
The system SHALL provide a `new_host` command in RUNME.sh that interactively creates a new NixOS host directory under `modules/HOSTS/` (uppercase) with minimal configuration files using the roles pattern.

#### Scenario: Successful host creation
- **WHEN** user runs `./RUNME.sh new_host`
- **THEN** the system prompts for hostname, type suffix, architecture, and roles using gum, creates `modules/HOSTS/<hostname>-<type>/` with `configuration.nix`, `hardware.nix`, and `networking.nix`

#### Scenario: Generated configuration.nix uses roles
- **WHEN** the host is created with roles `role-devbox` and `role-nebula-node` selected
- **THEN** `configuration.nix` contains `system-default`, `role-devbox`, and `role-nebula-node` in the imports block, and does NOT separately list `system-locale`, `hm-nixos`, `nix-cli`, or `user-pim`

#### Scenario: Missing gum dependency
- **WHEN** user runs `new_host` and gum is not installed
- **THEN** the system prints an error and exits with code 1

### Requirement: Correct directory paths
The functions `new_host`, `next_free_nebula_ip`, and `show_nebula_ip_allocation` SHALL use `modules/HOSTS/` (uppercase) for all path references.

#### Scenario: Nebula IP scanning uses correct path
- **WHEN** `next_free_nebula_ip` scans for used IPs
- **THEN** it searches `modules/HOSTS/*/networking.nix` (uppercase HOSTS)

#### Scenario: IP allocation display uses correct path
- **WHEN** `show_nebula_ip_allocation` lists current allocations
- **THEN** it reads from `modules/HOSTS/*/networking.nix` (uppercase HOSTS)

#### Scenario: Host directory created in correct location
- **WHEN** user creates a new host named "birdie" with type "laptop"
- **THEN** the directory is created at `modules/HOSTS/birdie-laptop/`

### Requirement: Hardware configuration auto-wrapping
The system SHALL read `/etc/nixos/hardware-configuration.nix`, extract its body content, and wrap it in the `flake.modules.nixos.<hostname>` pattern to produce `hardware.nix`.

#### Scenario: Hardware file exists
- **WHEN** `/etc/nixos/hardware-configuration.nix` exists
- **THEN** the function extracts the body (stripping function signature and outer braces) and writes it wrapped in `{ lib, inputs, ... }: { flake.modules.nixos.<hostname> = { config, pkgs, lib, ... }: { ... }; }`

#### Scenario: Hardware file missing
- **WHEN** `/etc/nixos/hardware-configuration.nix` does not exist
- **THEN** the system prints an error message and exits with code 1

### Requirement: Minimal configuration.nix generation
The system SHALL generate a `configuration.nix` that defines `flake.homeConfigurations`, `flake.nixosConfigurations`, and `flake.modules.nixos.<hostname>` with `system-default` and selected roles in the imports block.

#### Scenario: Generated configuration.nix structure
- **WHEN** the host is created
- **THEN** `configuration.nix` contains `makeHomeConf` with the hostname, `makeNixos` with the hostname and selected architecture, and a nixos module with `system.stateVersion = "25.11"` and the selected role imports

### Requirement: Networking.nix generation
The system SHALL generate a `networking.nix` that sets `networking.hostName` and `networking.firewall.enable = false`.

#### Scenario: Generated networking.nix structure
- **WHEN** the host is created
- **THEN** `networking.nix` contains `flake.modules.nixos.<hostname>` with `networking.hostName = hostname` and `networking.firewall.enable = false`

### Requirement: Nebula triggered by role selection
The system SHALL call `new_nebula_node` automatically when `role-nebula-node` is among the selected roles, replacing the previous separate nebula confirmation prompt.

#### Scenario: Nebula role selected
- **WHEN** user selects `role-nebula-node` in the role selector
- **THEN** the system calls `new_nebula_node` after creating the host files

#### Scenario: Nebula role not selected
- **WHEN** user does not select `role-nebula-node`
- **THEN** the system does not prompt for or create nebula certificates

### Requirement: Duplicate host prevention
The system SHALL check if the host directory already exists and refuse to overwrite it.

#### Scenario: Host directory already exists
- **WHEN** `modules/HOSTS/<hostname>-<type>/` already exists
- **THEN** the system prints an error and exits with code 1

### Requirement: Confirmation before creation
The system SHALL display a summary of what will be created and ask for confirmation before writing any files.

#### Scenario: User confirms
- **WHEN** user confirms the summary
- **THEN** files are created

#### Scenario: User cancels
- **WHEN** user declines confirmation
- **THEN** no files are created and the function exits cleanly
