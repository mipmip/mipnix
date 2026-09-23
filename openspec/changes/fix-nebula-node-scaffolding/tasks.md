## 1. Fix new_nebula_node guidance

- [ ] 1.1 In `RUNME.d/nebula.sh`, rewrite the "Next steps" gum message so step 1
      references adding `age.secrets` for `nebula-${hostname}-key`/`-cert` in
      `modules/HOSTS/<host>/networking.nix`, and step 2 references setting
      `services.nebula.networks.mesh.cert`/`.key` in the same file
- [ ] 1.2 Cite `modules/HOSTS/durer-server/networking.nix` as the template in the
      message, and note that the short node name (cert/hostname) may differ from
      the suffixed host directory (e.g. `durer` → `modules/HOSTS/durer-server/`)
- [ ] 1.3 Remove any reference to `hosts/$NODE_NAME/nebula.nix` and to a per-host
      `nebula.nix` file from the message
- [ ] 1.4 Confirm no other lines in `new_nebula_node` reference the removed
      `hosts/` layout (grep the function)

## 2. Verify unchanged functional behavior

- [ ] 2.1 Confirm cert output paths remain `secrets/nebula-<node>.crt.age` /
      `.key.age` and the existence check still guards them
- [ ] 2.2 Confirm the `secrets.nix` `sed` insert still targets the closing brace
      and emits `publicKeys = users ++ systems` lines matching existing entries
- [ ] 2.3 Do a dry read-through of the IP-allocation prompt path
      (`next_free_nebula_ip` / `show_nebula_ip_allocation`) — no code change
      expected, just verify the spec matches current behavior

## 3. Validate and sync specs

- [ ] 3.1 Run `openspec validate fix-nebula-node-scaffolding` and resolve any
      issues
- [ ] 3.2 Sanity-check the two new specs against reality: node naming
      (`durer` vs `durer-server`), the `age.secrets` + `mesh.cert/key` pattern in
      `modules/HOSTS/durer-server/networking.nix`, and the shared module
      `modules/services/networking/nebula.nix` (CA cert + sshd host key)
- [ ] 3.3 Optional smoke test: run `./RUNME.sh new_nebula_node` for a throwaway
      node name in a scratch checkout and confirm the corrected message prints,
      then discard the generated files
