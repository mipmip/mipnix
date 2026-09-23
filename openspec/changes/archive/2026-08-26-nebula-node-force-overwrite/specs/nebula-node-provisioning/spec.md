## ADDED Requirements

### Requirement: Certificate overwrite prompt

`new_nebula_node` SHALL prompt the operator to regenerate and overwrite the node's
certificates when they already exist (`secrets/nebula-<node>.crt.age` or
`secrets/nebula-<node>.key.age`) instead of aborting. On confirmation it SHALL proceed
with signing and overwrite the encrypted files. On decline it SHALL keep the existing
certificates, skip certificate generation, and continue with the remaining
provisioning steps (secrets and wiring). When `FORCE` is set the prompt SHALL be
treated as confirmed.

#### Scenario: Operator confirms regeneration

- **WHEN** `secrets/nebula-<node>.crt.age` already exists and the operator confirms the
  overwrite prompt
- **THEN** the command regenerates the certificate and overwrites the encrypted files

#### Scenario: Operator declines regeneration

- **WHEN** the node's certificates already exist and the operator declines the overwrite
  prompt
- **THEN** the command leaves the existing certificates untouched, does not exit, and
  continues to the secrets.nix and nebula.nix steps

#### Scenario: FORCE skips the prompt

- **WHEN** the node's certificates already exist and `FORCE` is set
- **THEN** the command regenerates and overwrites without prompting

### Requirement: FORCE overrides overwrite prompts

`new_nebula_node` SHALL treat every overwrite prompt as affirmatively answered when the
`FORCE` environment variable is set, enabling non-interactive re-provisioning. `new_host`
SHALL be able to pass this through so an automated host rebuild does not stall on prompts.

#### Scenario: Non-interactive forced run

- **WHEN** `FORCE=1` is set and one or more of the node's artifacts already exist
- **THEN** the command overwrites each existing artifact without displaying a prompt

## MODIFIED Requirements

### Requirement: Per-host nebula wiring file generation

After signing and encrypting a node's certificates, `new_nebula_node` SHALL
generate a `nebula.nix` file inside the node's host directory
(`modules/HOSTS/<node>-<type>/nebula.nix`) that declares the node's
`age.secrets."nebula-<node>-cert"` and `age.secrets."nebula-<node>-key"` (pointing
at the encrypted `.age` files, mounted under `/var/lib/nebula/` with owner
`nebula-mesh`) and sets `services.nebula.networks.mesh.cert` and `.key` to those
secret paths. The generated file SHALL define these under
`flake.modules.nixos.<node>` so it merges with the host's other modules and is
auto-loaded by `import-tree ./modules`. When the file already exists the command
SHALL prompt to overwrite it (or overwrite without prompting when `FORCE` is set);
on decline it SHALL leave the existing file unchanged and report so.

#### Scenario: Wiring file created for a new node

- **WHEN** `new_nebula_node` completes certificate generation for node `birdie`
  whose host directory is `modules/HOSTS/birdie-laptop`
- **THEN** `modules/HOSTS/birdie-laptop/nebula.nix` exists and declares
  `age.secrets."nebula-birdie-cert"` and `age.secrets."nebula-birdie-key"` and sets
  `services.nebula.networks.mesh.cert` / `.key` to those secrets' paths (referencing
  `nebula-birdie-*`, never another node's name)

#### Scenario: Host directory resolved from node name

- **WHEN** the host directory carries a type suffix (e.g. `modules/HOSTS/birdie-laptop`)
  and the node name is `birdie`
- **THEN** the command locates that directory (e.g. by globbing `modules/HOSTS/<node>-*`
  or using the directory supplied by the calling `new_host`) and writes `nebula.nix` into it

#### Scenario: Existing wiring file — operator confirms overwrite

- **WHEN** `modules/HOSTS/<node>-<type>/nebula.nix` already exists and the operator
  confirms the overwrite prompt (or `FORCE` is set)
- **THEN** the command regenerates the file, replacing the previous contents

#### Scenario: Existing wiring file — operator declines overwrite

- **WHEN** `modules/HOSTS/<node>-<type>/nebula.nix` already exists and the operator
  declines the overwrite prompt
- **THEN** the command SHALL NOT overwrite it and SHALL report that the file was left
  unchanged

### Requirement: Machine host key registration in secrets.nix

`new_nebula_node` SHALL register the node's machine identity in
`secrets/secrets.nix` so that `users ++ systems` secrets encrypt for the new host.
It SHALL add a `<node> = "ssh-ed25519 …";` let-binding using the machine's SSH
ed25519 host public key and SHALL append `<node>` to the `systems` list. This is in
addition to the existing insertion of the `nebula-<node>.crt.age` /
`nebula-<node>.key.age` `publicKeys` entries. When a let-binding for the node already
exists and its key **differs** from the machine's current host key, the command SHALL
prompt to overwrite the binding (or overwrite without prompting when `FORCE` is set);
when the existing key is identical it SHALL skip silently. `systems` membership and the
`publicKeys` entries remain add-if-absent (no prompt).

#### Scenario: Machine key added and joined to systems

- **WHEN** `new_nebula_node` provisions node `birdie` and reads its host public key
- **THEN** `secrets/secrets.nix` gains a `birdie = "ssh-ed25519 …";` let-binding and
  `birdie` is present in the `systems` list

#### Scenario: Existing machine key differs — operator confirms overwrite

- **WHEN** a `<node>` let-binding already exists but holds a different key, and the
  operator confirms the overwrite prompt (or `FORCE` is set)
- **THEN** the command replaces the binding with the machine's current host key and does
  not duplicate the binding or the `systems` entry

#### Scenario: Existing machine key is identical

- **WHEN** a `<node>` let-binding already exists with the same key
- **THEN** the command SHALL skip the binding update without prompting and SHALL NOT add a
  duplicate `systems` entry

#### Scenario: Host public key unavailable

- **WHEN** the machine's SSH ed25519 host public key cannot be read
- **THEN** the command SHALL warn that the machine key could not be registered and
  SHALL still complete certificate and wiring generation
