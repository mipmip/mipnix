## ADDED Requirements

### Requirement: Node naming convention

Each nebula node SHALL be identified by a short node name that is used
identically for the certificate file (`secrets/nebula-<node>.crt.age`), the
`hostname` variable in the host module, and the nebula certificate's `-name`.
This short node name is distinct from the host's directory under
`modules/HOSTS/`, which carries a role suffix.

#### Scenario: Short name is the shared identifier

- **WHEN** a host such as `durer` is wired for nebula
- **THEN** its certificate is `secrets/nebula-durer.crt.age`, its module sets
  `hostname = "durer"`, and its secrets are named `nebula-${hostname}-cert`/`-key`

#### Scenario: Directory carries a role suffix

- **WHEN** locating the host module for node `durer`
- **THEN** it lives at `modules/HOSTS/durer-server/` — the directory name (with its
  `-server`/`-laptop`/etc. suffix) differs from the short node name used in
  certificate and hostname references

### Requirement: Per-host nebula wiring

A host that participates in the mesh SHALL declare its node key and certificate as
agenix secrets and reference them from `services.nebula.networks.mesh`. The
secrets SHALL decrypt the repository's `secrets/nebula-${hostname}.key.age` and
`secrets/nebula-${hostname}.crt.age` to files under `/var/lib/nebula/` owned by
the `nebula-mesh` user.

#### Scenario: Host declares its nebula secrets

- **WHEN** a host module wires nebula in `modules/HOSTS/<host>/networking.nix`
- **THEN** it defines `age.secrets."nebula-${hostname}-key"` and
  `age.secrets."nebula-${hostname}-cert"` sourced from
  `../../../secrets + "/nebula-${hostname}.key.age"` and the matching `.crt.age`,
  each with `path` under `/var/lib/nebula/`, `owner = "nebula-mesh"`, and mode `600`

#### Scenario: Mesh network references the secret paths

- **WHEN** the host enables `services.nebula.networks.mesh`
- **THEN** `mesh.cert` and `mesh.key` are set to
  `config.age.secrets."nebula-${hostname}-cert".path` and
  `...-key".path` respectively

### Requirement: Shared nebula module

The system SHALL provide a shared nebula module at
`modules/services/networking/nebula.nix` that supplies the mesh-wide material
common to every node — the CA certificate and the sshd host key — as agenix
secrets under `/var/lib/nebula/` owned by `nebula-mesh`, and sets
`services.nebula.networks.mesh.ca` to the decrypted CA certificate path.

#### Scenario: CA and host key provided centrally

- **WHEN** a host enables the nebula role
- **THEN** the shared module decrypts `secrets/nebula-ca.crt.age` and
  `secrets/nebula-sshd-hostkey.age` to `/var/lib/nebula/`, and
  `services.nebula.networks.mesh.ca` points at the decrypted CA certificate

#### Scenario: Node-specific material stays in the host module

- **WHEN** the shared module is imported
- **THEN** it SHALL NOT hard-code any single node's cert/key, leaving the
  per-node `cert`/`key` wiring to the host module

### Requirement: Certificate recipients cover all mesh systems

Every nebula node certificate and key registered in `secrets/secrets.nix` SHALL
list `publicKeys = users ++ systems` so that agenix rekeys them for the mesh's
authorized users and systems.

#### Scenario: New node registered with mesh recipients

- **WHEN** a nebula node's `.crt.age`/`.key.age` are registered in
  `secrets/secrets.nix`
- **THEN** their `publicKeys` are `users ++ systems`, consistent with the existing
  `nebula-*` entries, so `./RUNME.sh rekey` re-encrypts them for every authorized
  recipient
