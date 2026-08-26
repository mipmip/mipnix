## Context

`new_nebula_node` (`RUNME.d/nebula.sh`) signs a nebula certificate for a node,
encrypts the cert/key with age, inserts the two `nebula-<node>.{crt,key}.age`
`publicKeys` lines into `secrets/secrets.nix`, and then prints a "Next steps" block
telling the operator to hand-write the per-host wiring. Two problems follow from
this manual tail:

1. The per-host wiring (age.secrets for the node's own cert/key + `services.nebula.
   networks.mesh.cert/.key`) is copied by hand. `modules/HOSTS/harry-pi/networking.nix`
   demonstrates the failure mode: it declares `nebula-harry-*` secrets but wires
   `mesh.cert/.key` to `nebula-lego2-*`.
2. The new machine's SSH host key is never added to `secrets.nix`, so it is absent
   from `systems`; `agenix rekey` therefore does not encrypt any `users ++ systems`
   secret for it — including the node's own nebula cert/key.

`new_host` (`RUNME.d/host.sh`) calls `new_nebula_node` when `role-nebula-node` is
selected. It knows the full host directory `modules/HOSTS/<name>-<type>` and runs on
the target machine (it requires `/etc/nixos/*`). `new_nebula_node` currently only
receives `HOST_NAME` (no type suffix) via env.

`import-tree ./modules` (flake.nix) auto-loads every `.nix` under `modules/`, so any
generated `modules/HOSTS/<host>/nebula.nix` is picked up with no manual import — this
is already how `harry-pi/_cloudflared.nix`, `_matrix.nix`, etc. are loaded.

## Goals / Non-Goals

**Goals:**
- Generate the per-host `nebula.nix` wiring automatically, correct-by-construction
  (secret names always match the node name).
- Register the machine's host key in `secrets.nix` (`<node>` let-binding + `systems`
  membership) so `rekey` covers the new host.
- Make re-runs safe: never clobber an existing `nebula.nix` or duplicate secrets.nix
  entries.
- Rewrite the stale "Next steps" advice.

**Non-Goals:**
- Running `agenix rekey`, `git commit`, or the rebuild automatically — these stay
  manual (destructive / require review).
- Fixing the pre-existing `harry-pi/networking.nix` cert/key bug (tracked separately;
  out of scope here).
- Changing certificate generation, IP allocation, or group selection logic.
- Migrating existing hosts' inline nebula wiring out of their `networking.nix`.

## Decisions

### Decision: Write a dedicated `nebula.nix`, not append to `networking.nix`
The generated wiring goes in its own `modules/HOSTS/<host>/nebula.nix` file defining
`flake.modules.nixos.<node> = { config, ... }: { … }`. A separate file is trivially
idempotent (create-if-absent), keeps generated content out of the hand-written
`networking.nix`, and is auto-merged by `import-tree` because module attrsets for the
same host compose. This matches the user's request ("added to `[host]/nebula.nix`")
and the existing `_matrix.nix`/`_cloudflared.nix` per-host-file convention.
_Alternative rejected:_ editing `networking.nix` in place — fragile sed surgery on a
hand-maintained file, and the current harry/lego2 inline style is exactly what
produced the copy-paste bug.

### Decision: Resolve the host directory by node name
`new_nebula_node` needs the full `<name>-<type>` directory but only has the node name.
Resolution order: (1) if the caller (`new_host`) exports the host directory, use it;
(2) otherwise glob `modules/HOSTS/<node>-*` and use the single match; (3) if zero or
multiple matches, skip file generation and warn (the cert/key work still succeeds).
This keeps `new_nebula_node` usable stand-alone without guessing the wrong directory.

### Decision: Source the machine key from the SSH host public key
The node's identity for agenix is its SSH ed25519 host public key. `new_host` runs on
the target machine, so read `/etc/ssh/ssh_host_ed25519_key.pub`. If it is missing or
unreadable, warn and continue (cert/key + wiring still complete) rather than aborting.
_Alternative rejected:_ prompting the operator to paste the key — more friction and a
transcription-error vector when the file is right there.

### Decision: Idempotent, guarded edits to secrets.nix
Before adding the `<node>` let-binding, grep for an existing `^\s*<node>\s*=` binding;
before appending to `systems`, check membership. The binding is inserted next to the
other host-key bindings; `systems` membership is inserted inside the existing
`systems = [ … ];` list. All edits are skipped (with a message) when already present,
so re-running the command — or running it after a partial previous run — is safe.

### Decision: Rewrite the closing message
Replace the "hand-write these files" next-steps with a summary of what was generated
plus the real remaining steps (`rekey`, commit, rebuild), consistent with the specs.

## Risks / Trade-offs

- [`sed`/text edits to `secrets.nix` could malform the Nix file] → Guard every edit
  behind an existence check, target well-known anchors (the `systems = [` list and the
  host-key binding block), and rely on the operator's rebuild/eval to catch a bad edit
  before it ships. Keep edits minimal and append-style.
- [Directory glob matches zero or multiple hosts] → Skip file generation and warn
  loudly rather than writing to the wrong place; the operator can drop the file in
  manually (the printed summary notes this case).
- [Stand-alone runs off the target machine cannot read the host key] → Degrade
  gracefully: warn, register nothing, and let the operator add the key later, then
  `rekey`.
- [Divergence from the existing inline `networking.nix` style on harry/lego2] →
  Accepted; new hosts use the cleaner dedicated-file pattern, existing hosts are left
  as-is (not in scope).

## Migration Plan

No data migration. The change is additive to `new_nebula_node`; existing hosts are
untouched. Rollout is simply landing the updated `RUNME.d/nebula.sh`. Rollback is
reverting that file — already-generated `nebula.nix` files and `secrets.nix` edits
remain valid Nix and can be kept or removed independently.

## Open Questions

- Should stand-alone `new_nebula_node` (not via `new_host`) prompt for the host
  directory / key path when auto-resolution fails, or is a warn-and-skip enough?
  (Current design: warn-and-skip.)
