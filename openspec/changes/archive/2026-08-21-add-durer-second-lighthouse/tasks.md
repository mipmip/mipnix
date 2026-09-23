## 1. Options and derivation

- [x] 1.1 Add `mipnix.nebula.lighthouses` option (attrset of nebula VPN IP → `"host:port"` endpoint) in `modules/services/networking/nebula.nix`
- [x] 1.2 Add `mipnix.nebula.isLighthouse` option (bool, default `false`) in the same module
- [x] 1.3 Refactor `flake.modules.nixos.networking-nebula` to derive `services.nebula.networks.mesh.isLighthouse` from `cfg.isLighthouse`
- [x] 1.4 Derive `services.nebula.networks.mesh.lighthouses` = `if cfg.isLighthouse then [] else builtins.attrNames cfg.lighthouses`
- [x] 1.5 Derive `services.nebula.networks.mesh.staticHostMap` = `builtins.mapAttrs (ip: ep: [ ep ]) cfg.lighthouses`
- [x] 1.6 Remove the old hardcoded `isLighthouse` / `lighthouses` / `staticHostMap` values

## 2. Registry and durer role

- [x] 2.1 Set `mipnix.nebula.lighthouses` to both entries: `"192.168.100.1" = "vaultwarden.tools.technative.cloud:4242"` and `"192.168.100.12" = "nuremberg.pimsnel.com:4242"`
- [x] 2.2 Add `mipnix.nebula.isLighthouse = true;` to durer in `modules/HOSTS/durer-server/networking.nix`

## 3. Evaluation checks (pre-deploy)

- [x] 3.1 `nix eval .#nixosConfigurations.durer.config.services.nebula.networks.mesh.isLighthouse` → `true`
- [x] 3.2 `nix eval .#nixosConfigurations.durer.config.services.nebula.networks.mesh.lighthouses` → `[]`
- [x] 3.3 `nix eval .#nixosConfigurations.durer.config.services.nebula.networks.mesh.staticHostMap` → contains both lighthouse entries
- [x] 3.4 On a non-lighthouse node (e.g. dapperehaan): `isLighthouse` → `false`, `lighthouses` → contains both IPs, `staticHostMap` → both entries

## 4. Rollout (in order; LAN fallback available for every node)

- [x] 4.1 Deploy durer first (public) so it becomes reachable lighthouse #2
- [x] 4.2 Redeploy dapperehaan (LAN `192.168.2.22`)
- [x] 4.3 Redeploy remaining nodes on the LAN — harry (192.168.2.43) and hurry (192.168.2.7) done and confirmed reporting to durer; laptops inherit the change on their next rebuild (also fixed a latent double-import of `networking-nebula` on harry/hurry/lavendel that the new option exposed)

## 5. Post-deploy verification

- [x] 5.1 On durer: `journalctl -u nebula@mesh` shows it serving as a lighthouse (`am_lighthouse: true`, `hosts: []`, active; peer reporting verified once nodes are redeployed)
- [x] 5.2 On dapperehaan: nebula handshake succeeds via durer (`Handshake message received certName=durer`); reaches durer `192.168.100.12` over the mesh (ping 2/2, ~19ms)
- [x] 5.3 Confirm a normal node still functions if the technative lighthouse `192.168.100.1` stays unreachable (failover to durer) — verified: `.1` times out, `.12` works, peer reachable
