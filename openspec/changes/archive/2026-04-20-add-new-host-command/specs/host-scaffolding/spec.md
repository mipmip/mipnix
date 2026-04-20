## ADDED Requirements

### Requirement: Interactive host creation command
The system SHALL provide a `new_host` command in RUNME.sh that interactively creates a new NixOS host directory with minimal configuration files.

#### Scenario: Successful host creation
- **WHEN** user runs `./RUNME.sh new_host`
- **THEN** the system prompts for hostname, type suffix, and architecture using gum, creates `modules/hosts/<hostname>-<type>/` with `configuration.nix`, `hardware.nix`, and `networking.nix`

#### Scenario: Missing gum dependency
- **WHEN** user runs `new_host` and gum is not installed
- **THEN** the system prints an error and exits with code 1

### Requirement: Hardware configuration auto-wrapping
The system SHALL read `/etc/nixos/hardware-configuration.nix`, extract its body content, and wrap it in the `flake.modules.nixos.<hostname>` pattern to produce `hardware.nix`.

#### Scenario: Hardware file exists
- **WHEN** `/etc/nixos/hardware-configuration.nix` exists
- **THEN** the function extracts the body (stripping function signature and outer braces) and writes it wrapped in `{ lib, inputs, ... }: { flake.modules.nixos.<hostname> = { config, pkgs, lib, ... }: { ... }; }`

#### Scenario: Hardware file missing
- **WHEN** `/etc/nixos/hardware-configuration.nix` does not exist
- **THEN** the system prints an error message and exits with code 1

### Requirement: Minimal configuration.nix generation
The system SHALL generate a `configuration.nix` that defines `flake.homeConfigurations`, `flake.nixosConfigurations`, and `flake.modules.nixos.<hostname>` with base imports: `system-default`, `system-locale`, `hm-nixos`, `nix-cli`, `user-pim`.

#### Scenario: Generated configuration.nix structure
- **WHEN** the host is created
- **THEN** `configuration.nix` contains `makeHomeConf` with the hostname, `makeNixos` with the hostname and selected architecture, and a nixos module with `system.stateVersion = "25.11"` and the base imports

### Requirement: Networking.nix generation
The system SHALL generate a `networking.nix` that sets `networking.hostName` and `networking.firewall.enable = false`.

#### Scenario: Generated networking.nix structure
- **WHEN** the host is created
- **THEN** `networking.nix` contains `flake.modules.nixos.<hostname>` with `networking.hostName = hostname` and `networking.firewall.enable = false`

### Requirement: Optional nebula setup
The system SHALL ask whether to set up nebula and, if confirmed, call the existing `new_nebula_node` function.

#### Scenario: User opts into nebula
- **WHEN** user confirms nebula setup
- **THEN** the system calls `new_nebula_node`

#### Scenario: User declines nebula
- **WHEN** user declines nebula setup
- **THEN** the system skips nebula and completes host creation

### Requirement: Duplicate host prevention
The system SHALL check if the host directory already exists and refuse to overwrite it.

#### Scenario: Host directory already exists
- **WHEN** `modules/hosts/<hostname>-<type>/` already exists
- **THEN** the system prints an error and exits with code 1

### Requirement: Confirmation before creation
The system SHALL display a summary of what will be created and ask for confirmation before writing any files.

#### Scenario: User confirms
- **WHEN** user confirms the summary
- **THEN** files are created

#### Scenario: User cancels
- **WHEN** user declines confirmation
- **THEN** no files are created and the function exits cleanly
