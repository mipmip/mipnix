## Why

After `new_nebula_node` generates a node's certificates it only *prints advice*
telling the operator to hand-write the per-host nebula wiring and to register the
new machine key for agenix. This manual step is error-prone — `harry-pi/networking.nix`
already ships a copy-paste bug where its `mesh.cert`/`mesh.key` point at
`nebula-lego2-*` instead of `nebula-harry-*` — and the printed instructions still
reference a `hosts/<node>/nebula.nix` path that no longer exists. Nothing adds the
new machine's SSH host key to `systems` in `secrets.nix`, so the freshly created
host cannot decrypt any `users ++ systems` secret until someone edits that file by
hand.

## What Changes

- `new_nebula_node` generates `modules/HOSTS/<host-dir>/nebula.nix` containing the
  node's `age.secrets` declarations (`nebula-<node>-cert` / `nebula-<node>-key`) and
  the `services.nebula.networks.mesh.cert` / `.key` wiring pointing at those secrets.
- `new_nebula_node` registers the new machine in `secrets/secrets.nix`: it adds a
  `<node> = "ssh-ed25519 …";` let-binding using the machine's SSH host public key and
  appends `<node>` to the `systems` list, so `users ++ systems` secrets (including the
  new node's own nebula cert/key entries) encrypt for it.
- The command's closing message replaces the stale "hand-write these files" advice
  with a summary of what was auto-created plus the remaining manual steps (`rekey`,
  commit, rebuild).
- Behaviour is idempotent/safe: the command refuses to clobber an existing
  `nebula.nix` or a machine key that is already registered.

## Capabilities

### New Capabilities
- `nebula-node-provisioning`: The `new_nebula_node` RUNME command's end-to-end
  provisioning behaviour — certificate generation (existing), plus automatic
  generation of the per-host `nebula.nix` wiring and registration of the machine's
  host key in `secrets.nix`.

### Modified Capabilities
<!-- No existing spec's requirements change; host-scaffolding still simply calls new_nebula_node. -->

## Impact

- `RUNME.d/nebula.sh` — `new_nebula_node` gains file generation + secrets.nix key
  registration; the "Next steps" message is rewritten.
- `secrets/secrets.nix` — auto-edited to add the machine key let-binding and the
  `systems` membership (in addition to the existing cert/key entry insertion).
- New generated file `modules/HOSTS/<host>-<type>/nebula.nix`, auto-loaded by
  `import-tree ./modules`.
- Operators still run `./RUNME.sh rekey`, commit, and rebuild afterwards.
- Relates to the `host-scaffolding` capability, which invokes `new_nebula_node` from
  `new_host` (the host directory path is supplied by that caller).
