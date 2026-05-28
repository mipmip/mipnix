## Context

dapperehaan-server is a home server NixOS machine (x86_64-linux) connected via Nebula VPN. It currently serves as a dev/samba/nebula node. We want to add a lightweight NixOS VM to host OpenClaw (in a follow-up change). The host already has `kvm-intel` kernel module loaded and `desktop-virt-virtualization` imported (libvirtd, virt-manager).

The mipnix repo uses flake-parts with `import-tree ./modules` for auto-discovery. Hosts live in `modules/HOSTS/<name>/` with three files: `configuration.nix`, `hardware.nix`, `networking.nix`.

## Goals / Non-Goals

**Goals:**
- Boot a minimal NixOS microvm guest on dapperehaan with outbound internet
- Persistent storage across reboots (for future OpenClaw state)
- Auto-start the VM as a systemd service
- Follow existing flake-parts conventions so the guest is auto-discovered

**Non-Goals:**
- Installing OpenClaw (follow-up change)
- Inbound services or port forwarding to the guest
- Nebula mesh for the guest
- GUI or desktop environment on the guest
- High-availability or migration between hosts

## Decisions

### Use microvm.nix with QEMU backend

Add `github:astro/microvm.nix` as a flake input. Use QEMU as the hypervisor backend.

**Why:** microvm.nix integrates natively with NixOS modules and flake-parts. QEMU is the most mature and flexible backend — Firecracker and cloud-hypervisor have more limitations around block devices and networking. Since dapperehaan already loads `kvm-intel`, QEMU/KVM will be hardware-accelerated.

**Alternatives considered:**
- libvirtd/virt-manager (already on host): More operational overhead, XML-based config doesn't fit the declarative Nix model
- NixOS containers (`nixos-container`): Shared kernel, less isolation
- Docker: Already explored with OpenClaw, hit packaging bugs; not declarative NixOS

### Guest defined in `modules/HOSTS/dapperehaan-server/guests/clawone-vm/`

Create a `guests/` subdirectory under the host. The guest's `configuration.nix` declares `flake.nixosConfigurations.clawone` and `flake.modules.nixos.clawone`.

**Why:** This preserves the parent-child relationship (guest belongs to host) while leveraging `import-tree` auto-discovery. The guest config is a first-class NixOS configuration in the flake, buildable independently (`nix build .#nixosConfigurations.clawone`).

**Alternatives considered:**
- Inline in dapperehaan's configuration.nix: Gets messy, mixes host and guest concerns
- Parallel `GUESTS/` directory: Loses the host-guest relationship in the file tree

### TAP networking with host NAT

Create a TAP interface (`vm-clawone`) bridged to the host's network via IP forwarding and masquerading (iptables NAT). The guest gets a static private IP (e.g., `10.0.100.2/24`), the host side is `10.0.100.1/24`.

**Why:** TAP is the standard microvm.nix networking approach. The guest only needs outbound HTTPS (OpenAI API, Matrix server), so simple NAT is sufficient. No bridge to the physical interface needed since we don't expose services.

**Alternatives considered:**
- User-mode networking (SLIRP): Simpler but slower and limited
- macvtap: Gives the guest a real LAN IP, but unnecessary and more complex for outbound-only

### Minimal guest NixOS config

The guest runs: systemd, networkd, sshd (for debugging from host), and nothing else. No desktop, no dev tools, no user home-manager yet.

**Why:** Keep the first proposal minimal to validate the infrastructure. OpenClaw and home-manager come in proposal 2.

## Risks / Trade-offs

[Risk] microvm.nix is a new flake input, adding build complexity → Mitigation: Pin to a stable release tag, keep guest config minimal

[Risk] TAP/NAT networking may conflict with existing firewall rules (dapperehaan has `firewall.enable = false`) → Mitigation: Since firewall is disabled, NAT rules just need IP forwarding enabled and a masquerade rule. Low conflict risk.

[Risk] `import-tree` may not handle the nested `guests/` path correctly → Mitigation: Test with `nix flake show` before deploying. The import-tree module should discover any `.nix` file recursively.

[Risk] Persistent volume data loss on `nixos-rebuild` → Mitigation: microvm.nix persistent volumes survive rebuilds by design; they live in `/var/lib/microvms/`.
