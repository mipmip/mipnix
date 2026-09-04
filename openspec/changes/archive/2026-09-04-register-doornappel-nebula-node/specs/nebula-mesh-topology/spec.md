## MODIFIED Requirements

### Requirement: Single-source node-IP registry

The nebula mesh configuration SHALL declare every node's overlay IP in one place via
a `flake.nebulaNodes` registry: an attribute set mapping each active node's name to
its nebula VPN IP, assembled from per-host contributions merged across the module
tree (the same pattern as `flake.deploy`). Each host SHALL declare its own IP exactly
once through `flake.nebulaNodes.<name>`, and no other artifact SHALL repeat that
name/IP pair. A host that runs the nebula role (has signed mesh certificates and
imports `role-nebula-node`) SHALL contribute a registry entry; a host that holds mesh
certificates but is absent from the registry is a defect, not an opt-out.

#### Scenario: Every active node appears in the registry

- **WHEN** the flake is evaluated
- **THEN** `flake.nebulaNodes` SHALL contain an entry for each active nebula node —
  `dapperehaan`, `doornappel`, `durer`, `harry`, `hurry`, `lavendel`, `cichorei`, and
  `zonnehoed` — mapping its name to its overlay IP

#### Scenario: doornappel is registered at its certificate IP

- **WHEN** the flake is evaluated
- **THEN** `flake.nebulaNodes.doornappel` SHALL be `192.168.100.15`, matching the IP
  carried by doornappel's signed nebula certificate and assigned to its
  `nebula.mesh` interface

#### Scenario: A node declares its IP once

- **WHEN** a host contributes `flake.nebulaNodes.<name> = "<ip>"` from its own module
- **THEN** that entry SHALL be the sole in-Nix declaration of the node's overlay IP,
  and any other consumer (such as `networking.extraHosts`) SHALL derive from it
  rather than restating the IP

### Requirement: Host /etc/hosts entry derived from the registry

Each host's `networking.extraHosts` nebula self-entry SHALL be derived from its
`flake.nebulaNodes` registry entry rather than from a hard-coded IP literal, so that
changing a node's IP requires editing only the registry. Because every node's
`extraHosts` is derived from the whole registry, an unregistered node SHALL be
unresolvable by name from every other node.

#### Scenario: extraHosts reflects the registry IP

- **WHEN** `flake.nebulaNodes.durer` is `192.168.100.12`
- **THEN** durer's `networking.extraHosts` SHALL contain `192.168.100.12 durer`
  produced from that registry entry, with no separately maintained IP literal

#### Scenario: doornappel resolves by name across the mesh

- **WHEN** `flake.nebulaNodes.doornappel` is `192.168.100.15`
- **THEN** every mesh node's `/etc/hosts` SHALL contain `192.168.100.15 doornappel`
