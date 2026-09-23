## 1. Wire it in

- [x] 1.1 Add `nivis-tunnel` as a flake input following mipnix nixpkgs; verify `nix flake lock` resolves it
- [x] 1.2 Add `networking-nivis-tunnel-relay` wrapping the upstream module, with the port opened deliberately; verify the module appears in `self.modules.nixos`
- [x] 1.3 Import it in durer; verify `nixosConfigurations.durer` builds

## 2. Verify before deploying

- [x] 2.1 Confirm the unit exists in the built system and carries the expected hardening; verify `CapabilityBoundingSet=`, `DynamicUser=true`, `ProtectSystem=strict` and the inet-only address families
- [x] 2.2 Confirm the firewall gains 7843 and nothing else; verify `allowedTCPPorts` is `[22 80 443 7843]`
- [x] 2.3 Deploy and confirm the unit is active on durer
- [x] 2.4 Confirm the port answers from outside; verify with a connection from a machine that is not durer

## 3. Close

- [x] 3.1 Update bean `mipnix-ub5r` with a `## Summary of Changes` section and set it to `completed`

## 4. Verified after deploying

Checked against the running machine, not the configuration:

- [x] 4.1 `systemctl is-active nivis-tunnel-relay` → `active`, `NRestarts=0`
- [x] 4.2 Listening on `[::]:7843`; `iptables -L nixos-fw` accepts `dpt:7843`
- [x] 4.3 Reachable from outside over the public address (`nuremberg.pimsnel.com`, 178.104.252.76)
- [x] 4.4 **A real rendezvous over the public internet.** A local agent and a local client, both dialling durer, were paired; the Noise handshake completed and a payload round-tripped. durer's own log:
      ```
      parked        stream=durer-check-02 role=agent
      paired        stream=durer-check-02 role=orchestrator with=agent
      session ended stream=durer-check-02
      ```
- [x] 4.5 A bare TCP probe was refused with a legible reason and **without logging an unvalidated stream id**: `refused connection reason="proto: reading frame header: unexpected EOF"`
- [x] 4.6 The deploy was additive: nginx, postgresql, docker and nebula@mesh all still `active`
