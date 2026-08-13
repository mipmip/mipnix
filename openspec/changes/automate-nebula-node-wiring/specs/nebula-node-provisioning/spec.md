## ADDED Requirements

### Requirement: Per-host nebula wiring file generation

After signing and encrypting a node's certificates, `new_nebula_node` SHALL
generate a `nebula.nix` file inside the node's host directory
(`modules/HOSTS/<node>-<type>/nebula.nix`) that declares the node's
`age.secrets."nebula-<node>-cert"` and `age.secrets."nebula-<node>-key"` (pointing
at the encrypted `.age` files, mounted under `/var/lib/nebula/` with owner
`nebula-mesh`) and sets `services.nebula.networks.mesh.cert` and `.key` to those
secret paths. The generated file SHALL define these under
`flake.modules.nixos.<node>` so it merges with the host's other modules and is
auto-loaded by `import-tree ./modules`.

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

#### Scenario: Existing wiring file is not clobbered

- **WHEN** `modules/HOSTS/<node>-<type>/nebula.nix` already exists
- **THEN** the command SHALL NOT overwrite it and SHALL report that the file was left
  unchanged

### Requirement: Machine host key registration in secrets.nix

`new_nebula_node` SHALL register the node's machine identity in
`secrets/secrets.nix` so that `users ++ systems` secrets encrypt for the new host.
It SHALL add a `<node> = "ssh-ed25519 …";` let-binding using the machine's SSH
ed25519 host public key and SHALL append `<node>` to the `systems` list. This is in
addition to the existing insertion of the `nebula-<node>.crt.age` /
`nebula-<node>.key.age` `publicKeys` entries.

#### Scenario: Machine key added and joined to systems

- **WHEN** `new_nebula_node` provisions node `birdie` and reads its host public key
- **THEN** `secrets/secrets.nix` gains a `birdie = "ssh-ed25519 …";` let-binding and
  `birdie` is present in the `systems` list

#### Scenario: Machine key already registered

- **WHEN** a let-binding for the node name already exists in `secrets/secrets.nix`
- **THEN** the command SHALL NOT add a duplicate binding and SHALL NOT add a duplicate
  `systems` entry

#### Scenario: Host public key unavailable

- **WHEN** the machine's SSH ed25519 host public key cannot be read
- **THEN** the command SHALL warn that the machine key could not be registered and
  SHALL still complete certificate and wiring generation

### Requirement: Closing guidance reflects automated wiring

The command's success message SHALL summarize what was auto-created (the per-host
`nebula.nix`, the `secrets.nix` machine-key and `systems` registration) and SHALL
list only the genuinely remaining manual steps: running `./RUNME.sh rekey`,
committing, and rebuilding. It SHALL NOT instruct the operator to hand-write the
per-host nebula wiring or to manually register the machine key.

#### Scenario: Success message after provisioning

- **WHEN** `new_nebula_node` finishes provisioning a node
- **THEN** the printed next steps mention `rekey`, commit, and rebuild, and do not tell
  the operator to create `nebula.nix` by hand or to add `age.secrets` / `services.nebula`
  manually
