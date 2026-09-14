## 1. Wire it in

- [x] 1.1 Add `nivis-tunnel` as a flake input following mipnix nixpkgs; verify `nix flake lock` resolves it
- [x] 1.2 Add `networking-nivis-tunnel-relay` wrapping the upstream module, with the port opened deliberately; verify the module appears in `self.modules.nixos`
- [x] 1.3 Import it in durer; verify `nixosConfigurations.durer` builds

## 2. Verify before deploying

- [x] 2.1 Confirm the unit exists in the built system and carries the expected hardening; verify `CapabilityBoundingSet=`, `DynamicUser=true`, `ProtectSystem=strict` and the inet-only address families
- [x] 2.2 Confirm the firewall gains 7843 and nothing else; verify `allowedTCPPorts` is `[22 80 443 7843]`
- [ ] 2.3 Deploy and confirm the unit is active on durer
- [ ] 2.4 Confirm the port answers from outside; verify with a connection from a machine that is not durer

## 3. Close

- [ ] 3.1 Update bean `mipnix-ub5r` with a `## Summary of Changes` section and set it to `completed`
