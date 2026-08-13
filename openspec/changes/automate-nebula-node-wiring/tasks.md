## 1. Host directory resolution

- [x] 1.1 In `new_nebula_node`, determine the node's host directory: use a caller-supplied
      value (`HOST_DIR` from `new_host`) if set, else glob `modules/HOSTS/<NODE_NAME>-*`
- [x] 1.2 Handle zero / multiple glob matches by warning and skipping file generation
      (cert/key work still completes)
- [x] 1.3 Update `new_host` (`RUNME.d/host.sh`) to export `HOST_DIR` before it calls
      `new_nebula_node`

## 2. Generate per-host nebula.nix

- [x] 2.1 Add a helper that writes `<host-dir>/nebula.nix` defining
      `flake.modules.nixos.<node>` with `age.secrets."nebula-<node>-cert"` and
      `"nebula-<node>-key"` (files `../../../secrets/nebula-<node>.{crt,key}.age`,
      paths under `/var/lib/nebula/`, owner `nebula-mesh`, mode `600`)
- [x] 2.2 In the same module set `services.nebula.networks.mesh.cert` / `.key` to those
      secret paths, always referencing `nebula-<node>-*` (no other node's name)
- [x] 2.3 Guard the write: if `<host-dir>/nebula.nix` already exists, skip and report it
      left unchanged

## 3. Register machine key in secrets.nix

- [x] 3.1 Read the machine's SSH ed25519 host public key from
      `/etc/ssh/ssh_host_ed25519_key.pub`; warn-and-skip registration if unreadable
- [x] 3.2 If no `<node> = "ssh-ed25519 …";` let-binding exists in `secrets/secrets.nix`,
      insert one alongside the other host-key bindings
- [x] 3.3 If `<node>` is not already in the `systems = [ … ];` list, append it
- [x] 3.4 Ensure both edits are idempotent (no duplicates on re-run) and preserve the
      existing insertion of the `nebula-<node>.{crt,key}.age` `publicKeys` entries

## 4. Update command output

- [x] 4.1 Rewrite the "Next steps" success message to summarize what was auto-created
      (nebula.nix, machine key + systems membership) and list only `rekey`, commit,
      rebuild as remaining manual steps
- [x] 4.2 Remove the stale advice to hand-write `age.secrets` / `services.nebula` wiring

## 5. Verification

- [x] 5.1 Dry-run `new_nebula_node` for a throwaway node name and confirm the generated
      `nebula.nix` references only that node's cert/key
- [x] 5.2 Confirm `secrets/secrets.nix` still evaluates (`nix eval` / a rebuild dry-run)
      after the machine-key and `systems` edits
- [x] 5.3 Re-run the command and confirm idempotency (no clobbered file, no duplicate
      secrets.nix entries)
