## 0. Context

Root cause: `modules/HOSTS/doornappel-laptop/networking.nix` never sets
`flake.nebulaNodes.doornappel`. doornappel has signed mesh certs
(`secrets/nebula-doornappel.{crt,key}.age`), imports `role-nebula-node`, and is up on
`192.168.100.15` (`ip addr show nebula.mesh`) — but it is absent from the registry
that feeds both `networking.extraHosts` (shared nebula module) and
`self.lib.nebulaHosts` (the `Prefix + H` tmux picker). So it is missing from the
picker on cichorei and unresolvable by name from every other node.

Every other registered host declares this in its own `networking.nix`
(see `modules/HOSTS/cichorei-laptop/networking.nix:8`).

Schema source: https://github.com/speclib/openspec-tinychange-schema

## 1. Implementation

- [x] 1.1 Add `flake.nebulaNodes.doornappel = "192.168.100.15";` at the top level of
      `modules/HOSTS/doornappel-laptop/networking.nix` (outside
      `flake.modules.nixos.doornappel`, matching the placement in
      `modules/HOSTS/cichorei-laptop/networking.nix`).

## 2. Verification

- [x] 2.1 `nix eval .#nebulaNodes` lists `doornappel = "192.168.100.15"` alongside the
      other nodes.
- [x] 2.2 `nix eval .#lib.nebulaHosts` includes `"doornappel 192.168.100.15"`.
- [x] 2.3 `nix eval .#nixosConfigurations.cichorei.config.networking.extraHosts` contains
      `192.168.100.15 doornappel`.
- [x] 2.4 The `nebula-ssh` picker script built for cichorei's home configuration bakes
      in `doornappel 192.168.100.15` (built and inspected via
      `nix build --impure --expr` on
      `homeConfigurations."pim@cichorei".config.home.packages`). The interactive
      `Prefix + H` check still needs a home-manager switch on cichorei itself —
      applied from doornappel, so it could not be run here.

## 3. Follow-up (out of scope — not a task of this change)

`new_nebula_node` (`RUNME.d/nebula.sh`) generates the per-host `nebula.nix` and the
`secrets.nix` wiring but does NOT write the `flake.nebulaNodes.<name>` registry
entry — which is how doornappel slipped through. Worth a separate change against the
`nebula-node-provisioning` spec.
