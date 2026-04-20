## MODIFIED Requirements

### Requirement: Interactive host creation command
The system SHALL provide a `new_host` command in RUNME.sh that interactively creates a new NixOS host directory under `modules/HOSTS/` (uppercase) with minimal configuration files using the roles pattern.

#### Scenario: Successful host creation
- **WHEN** user runs `./RUNME.sh new_host`
- **THEN** the system prompts for hostname, type suffix, architecture, and roles using gum, creates `modules/HOSTS/<hostname>-<type>/` with `configuration.nix`, `hardware.nix`, and `networking.nix`

#### Scenario: Generated configuration.nix uses roles
- **WHEN** the host is created with roles `role-devbox` and `role-nebula-node` selected
- **THEN** `configuration.nix` contains `system-default`, `role-devbox`, and `role-nebula-node` in the imports block, and does NOT separately list `system-locale`, `hm-nixos`, `nix-cli`, or `user-pim`

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
