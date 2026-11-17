## 1. Configuration

- [x] 1.1 Set `networking.firewall.enable = true` in `modules/HOSTS/delliebellie-laptop/networking.nix`
- [x] 1.2 Add `networking.firewall.interfaces."nebula.mesh".allowedTCPPorts = [ 22000 ]` to the pool configuration in `modules/services/sync/syncthing-pool.nix`

## 2. Verification

- [x] 2.1 `nix eval --impure` on delliebellie's `config.networking.firewall` shows `enable = true`, TCP 22, UDP 5353, TCP 22000 on `nebula.mesh`, and TCP 9100 on `nebula.mesh`
- [x] 2.2 `nix eval --impure` on a host that is not delliebellie shows its firewall state unchanged
- [x] 2.3 `nix build --impure .#nixosConfigurations.delliebellie.config.system.build.toplevel` succeeds
- [x] 2.4 After `rme up_machine` on delliebellie, syncthing has established peer connections and the Work folder converges
