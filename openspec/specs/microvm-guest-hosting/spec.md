## ADDED Requirements

### Requirement: Flake provides microvm.nix host support
The flake SHALL include `microvm.nix` as an input and the dapperehaan host module SHALL import the microvm host module to enable guest VM management.

#### Scenario: microvm input available in flake
- **WHEN** the flake is evaluated
- **THEN** `inputs.microvm` SHALL resolve to the microvm.nix flake

#### Scenario: dapperehaan imports microvm host module
- **WHEN** dapperehaan's NixOS configuration is built
- **THEN** the microvm host module SHALL be imported, enabling `microvm.vms` declarations

### Requirement: clawone guest is a declarative NixOS configuration
The flake SHALL declare `flake.nixosConfigurations.clawone` as a full NixOS system configuration, auto-discovered by `import-tree` from `modules/HOSTS/dapperehaan-server/guests/clawone-vm/`.

#### Scenario: Guest config is discoverable
- **WHEN** `nix flake show` is run
- **THEN** `nixosConfigurations.clawone` SHALL appear in the output

#### Scenario: Guest config builds independently
- **WHEN** `nix build .#nixosConfigurations.clawone.config.system.build.toplevel` is run
- **THEN** the build SHALL succeed without requiring the host to be present

### Requirement: Guest VM runs with specified resources
The clawone guest SHALL be configured with 2 vCPUs, 2048 MB RAM, and an 8 GB persistent volume using the QEMU hypervisor backend.

#### Scenario: Resource allocation
- **WHEN** the microvm@clawone service starts
- **THEN** QEMU SHALL be launched with 2 vCPUs and 2048 MB memory

#### Scenario: Persistent storage
- **WHEN** the guest writes data to its root filesystem
- **AND** the VM is restarted
- **THEN** the written data SHALL persist

### Requirement: Guest auto-starts on host boot
The clawone guest SHALL run as a systemd service (`microvm@clawone.service`) that starts automatically when dapperehaan boots.

#### Scenario: Auto-start after reboot
- **WHEN** dapperehaan-server reboots
- **THEN** `microvm@clawone.service` SHALL be in `active (running)` state without manual intervention

### Requirement: Guest has outbound internet access
The guest SHALL have outbound network connectivity via a TAP interface with NAT on the host. The guest SHALL be able to reach external HTTPS endpoints.

#### Scenario: Outbound HTTPS connectivity
- **WHEN** `curl https://api.openai.com` is run inside the guest
- **THEN** the request SHALL receive an HTTP response (not a connection error)

#### Scenario: Outbound Matrix connectivity
- **WHEN** `curl https://nuremberg.pimsnel.com` is run inside the guest
- **THEN** the request SHALL receive an HTTP response

### Requirement: Guest has SSH access from host
The guest SHALL run an SSH server accessible from the host for debugging and administration purposes.

#### Scenario: SSH from host to guest
- **WHEN** `ssh <guest-ip>` is run from the dapperehaan host
- **THEN** an SSH session SHALL be established to the guest
