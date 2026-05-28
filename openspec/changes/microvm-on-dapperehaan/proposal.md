## Why

We want to run an OpenClaw AI assistant as a persistent service on dapperehaan-server (home server, connected via Nebula VPN). Rather than installing OpenClaw directly on the host, we use a microvm.nix guest to keep it isolated and declaratively managed. This first change sets up the microvm infrastructure — a bootable NixOS guest with outbound internet — so the follow-up change can layer OpenClaw on top without debugging infra and app issues simultaneously.

## What Changes

- Add `microvm.nix` as a new flake input
- Import `microvm.nixosModules.host` on dapperehaan-server to enable microvm hosting
- Create `modules/HOSTS/dapperehaan-server/guests/clawone-vm/` with guest NixOS configuration following existing flake-parts patterns
- Declare `flake.nixosConfigurations.clawone` via the existing `import-tree` auto-discovery
- Configure the guest: QEMU backend, 2 vCPUs, 2 GB RAM, 8 GB persistent volume
- Set up TAP networking with NAT for outbound HTTPS (no inbound services needed)
- Guest runs as `microvm@clawone.service` (systemd, auto-start on boot)

## Capabilities

### New Capabilities
- `microvm-guest-hosting`: Declares microvm.nix host support on dapperehaan and defines the clawone-vm guest with compute resources, persistent storage, and outbound networking

### Modified Capabilities

None.

## Impact

- `flake.nix`: New input (`microvm`)
- `modules/HOSTS/dapperehaan-server/configuration.nix`: Import microvm host module
- New directory `modules/HOSTS/dapperehaan-server/guests/clawone-vm/`: Guest configuration and networking
- dapperehaan will need a `nixos-rebuild switch` to deploy
- Host networking: needs NAT/forwarding rules for the guest's TAP interface
