## 1. Flake Input Setup

- [x] 1.1 Add `microvm` input to `flake.nix` pointing to `github:astro/microvm.nix`
- [x] 1.2 Verify flake evaluates cleanly with `nix flake show`

## 2. Host Configuration (dapperehaan)

- [x] 2.1 Import `inputs.microvm.nixosModules.host` in dapperehaan's `configuration.nix` imports list
- [x] 2.2 Enable IP forwarding on the host (`boot.kernel.sysctl."net.ipv4.ip_forward" = 1`)
- [x] 2.3 Add iptables NAT masquerade rule for the guest subnet (10.0.100.0/24) on the host
- [x] 2.4 Declare the clawone microvm in dapperehaan's config: TAP interface `vm-clawone`, host-side IP `10.0.100.1/24`

## 3. Guest Configuration (clawone-vm)

- [x] 3.1 Create directory `modules/HOSTS/dapperehaan-server/guests/clawone-vm/`
- [x] 3.2 Create `configuration.nix` declaring `flake.nixosConfigurations.clawone` via `self.lib.makeNixos` and `flake.modules.nixos.clawone` with microvm guest settings (2 vCPU, 2048 MB RAM, QEMU backend, 8 GB persistent volume)
- [x] 3.3 Create `networking.nix` with guest-side static IP (`10.0.100.2/24`), default gateway (`10.0.100.1`), DNS, and hostname
- [x] 3.4 Enable `services.openssh.enable = true` on the guest for host-to-guest SSH access
- [x] 3.5 Add a user account (pim) with SSH authorized key for access from host

## 4. Verification

- [x] 4.1 Verify clawone module is discovered by import-tree and evaluates via dapperehaan's microvm.vms
- [x] 4.2 Build dapperehaan config (includes clawone guest): `nix build .#nixosConfigurations.dapperehaan.config.system.build.toplevel`
- [ ] 4.3 Deploy to dapperehaan with `nixos-rebuild switch`
- [ ] 4.4 Verify `microvm@clawone.service` is running on the host
- [ ] 4.5 SSH from host to guest (`ssh pim@10.0.100.2`)
- [ ] 4.6 From inside the guest, verify outbound HTTPS: `curl -s https://nuremberg.pimnsnel.com` and `curl -s https://api.openai.com`
