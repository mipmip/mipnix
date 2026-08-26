## 1. Node-IP registry

- [ ] 1.1 Add a `flake.nebulaNodes` option module (mergeable `lazyAttrsOf`, mirroring `modules/nix/deploy-option.nix`) mapping node name → overlay IP
- [ ] 1.2 Add a `self.lib.nebulaHosts` helper in `modules/nix/helpers.nix` that folds `flake.nebulaNodes` into `"<name> <ip>"` lines
- [ ] 1.3 Capture `cichorei`'s nebula IP via `./RUNME.sh nebula_hosts` (decrypts certs; needs SSH passphrase) — do not guess it

## 2. Per-host registry entries + extraHosts rewire

- [ ] 2.1 `durer`: add `flake.nebulaNodes.durer` and derive its `extraHosts` nebula line from the registry
- [ ] 2.2 `dapperehaan`: add `flake.nebulaNodes.dapperehaan` and derive its `extraHosts` nebula line from the registry
- [ ] 2.3 `hurry`: add `flake.nebulaNodes.hurry` and derive its `extraHosts` nebula line from the registry
- [ ] 2.4 `harry`: add `flake.nebulaNodes.harry` and derive its `extraHosts` nebula line from the registry
- [ ] 2.5 `lavendel`: add `flake.nebulaNodes.lavendel` and derive its `extraHosts` nebula line from the registry
- [ ] 2.6 `cichorei`: add `flake.nebulaNodes.cichorei` (captured in 1.3) and add its derived `extraHosts` nebula line
- [ ] 2.7 Confirm no node/IP pair is now declared twice in Nix (registry is the sole in-Nix source)

## 3. tmux picker

- [ ] 3.1 Add a `pkgs.writeShellScriptBin "nebula-ssh"` in `modules/USERS/pim/programs/tmux/default.nix` that bakes `self.lib.nebulaHosts` and runs `fzf`
- [ ] 3.2 Implement the connect flow: ensure `nebula-prive` session, create-or-select a window named after the host running `ssh pim@<ip>`, then `switch-client`
- [ ] 3.3 Handle cancel: Escape / empty selection exits cleanly and creates nothing
- [ ] 3.4 Add `bind H popup -E ... nebula-ssh` beside the existing `bind S/G/B` launchers

## 4. Verify

- [ ] 4.1 Build: `nixos-rebuild` / home-manager switch succeeds with no eval error or `inputs.self` recursion
- [ ] 4.2 `Prefix + H` lists all six nodes (`durer`, `dapperehaan`, `hurry`, `harry`, `lavendel`, `cichorei`) and excludes `peterspav` / `_lego2`
- [ ] 4.3 Selecting a host opens `nebula-prive:<host>` and connects via SSH; selecting it again reuses the window; Escape closes the popup cleanly
- [ ] 4.4 A rebuilt host's `/etc/hosts` still shows its own `192.168.100.x <name>` line (extraHosts unchanged in effect)
