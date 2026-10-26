## ADDED Requirements

### Requirement: Certificate generation and file naming

The `new_nebula_node` command SHALL generate a nebula node key/certificate pair
signed by the mesh CA and store them age-encrypted under `secrets/` using the
node's short name, as `secrets/nebula-<node>.crt.age` and
`secrets/nebula-<node>.key.age`.

#### Scenario: New node certificates created

- **WHEN** the user runs `./RUNME.sh new_nebula_node` and supplies a node name, an
  IP in CIDR notation, and (optionally) groups
- **THEN** `nebula-cert sign` produces a cert/key for that name and IP, and the
  files are written age-encrypted to `secrets/nebula-<node>.crt.age` and
  `secrets/nebula-<node>.key.age`

#### Scenario: Node already exists

- **WHEN** `secrets/nebula-<node>.crt.age` or `secrets/nebula-<node>.key.age`
  already exists for the requested node name
- **THEN** the command SHALL abort with an error and create no files

### Requirement: Registration in secrets.nix

The `new_nebula_node` command SHALL register the two new age files in
`secrets/secrets.nix` so agenix can rekey them for all authorized recipients,
inserting entries of the form `"nebula-<node>.crt.age".publicKeys = users ++
systems;` (and the matching `.key.age`) before the closing brace of the
attribute set.

#### Scenario: Entries appended before closing brace

- **WHEN** certificates for a new node are created
- **THEN** two lines assigning `publicKeys = users ++ systems` for the node's
  `.crt.age` and `.key.age` are inserted before the final `}` of
  `secrets/secrets.nix`, matching the existing nebula entries' form

#### Scenario: Rekey guidance

- **WHEN** registration completes
- **THEN** the command SHALL instruct the operator to run `./RUNME.sh rekey` to
  re-encrypt the new secrets for all authorized systems

### Requirement: Nebula IP allocation

The provisioning workflow SHALL suggest the next free nebula IP by inspecting the
existing `secrets/nebula-*.crt.age` certificates, and SHALL let the operator
accept or override the suggestion.

#### Scenario: Suggested IP offered

- **WHEN** the operator is prompted for the node IP
- **THEN** `next_free_nebula_ip` scans the existing nebula certificates and
  pre-fills the prompt with the next unused address, and `show_nebula_ip_allocation`
  lists current allocations

#### Scenario: Invalid CIDR rejected

- **WHEN** the operator supplies an address that is not in `A.B.C.D/N` CIDR form
- **THEN** the command SHALL abort with an error and create no certificates

### Requirement: Post-creation guidance matches the modules/HOSTS layout

After creating certificates, the `new_nebula_node` command SHALL print next-step
guidance that references the current dendritic repository layout. It SHALL direct
the operator to `modules/HOSTS/<host>/networking.nix` and MUST NOT reference the
removed `hosts/<node>/nebula.nix` path.

#### Scenario: Guidance points at the real wiring location

- **WHEN** the "Next steps" message is printed after certificate creation
- **THEN** it instructs the operator to add `age.secrets` for
  `nebula-${hostname}-key` and `nebula-${hostname}-cert` and to set
  `services.nebula.networks.mesh.cert`/`.key` inside
  `modules/HOSTS/<host>/networking.nix`, referencing an existing host such as
  `modules/HOSTS/durer-server/networking.nix` as a template

#### Scenario: No reference to the removed layout

- **WHEN** the "Next steps" message is printed
- **THEN** it SHALL NOT mention a `hosts/` directory or a per-host `nebula.nix`
  file, because neither exists in the current structure

#### Scenario: Node name versus host directory distinction

- **WHEN** the guidance refers to the host that will use the certificate
- **THEN** it SHALL make clear that the short node name (the certificate name) may
  differ from the suffixed host directory (for example node `durer` lives in
  `modules/HOSTS/durer-server/`)
