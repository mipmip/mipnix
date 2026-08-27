## ADDED Requirements

### Requirement: Single-source node-IP registry

The nebula mesh configuration SHALL declare every node's overlay IP in one place via
a `flake.nebulaNodes` registry: an attribute set mapping each active node's name to
its nebula VPN IP, assembled from per-host contributions merged across the module
tree (the same pattern as `flake.deploy`). Each host SHALL declare its own IP exactly
once through `flake.nebulaNodes.<name>`, and no other artifact SHALL repeat that
name/IP pair.

#### Scenario: Every active node appears in the registry

- **WHEN** the flake is evaluated
- **THEN** `flake.nebulaNodes` SHALL contain an entry for each active nebula node —
  `durer`, `dapperehaan`, `hurry`, `harry`, `lavendel`, and `cichorei` — mapping its
  name to its overlay IP

#### Scenario: A node declares its IP once

- **WHEN** a host contributes `flake.nebulaNodes.<name> = "<ip>"` from its own module
- **THEN** that entry SHALL be the sole in-Nix declaration of the node's overlay IP,
  and any other consumer (such as `networking.extraHosts`) SHALL derive from it
  rather than restating the IP

### Requirement: Host /etc/hosts entry derived from the registry

Each host's `networking.extraHosts` nebula self-entry SHALL be derived from its
`flake.nebulaNodes` registry entry rather than from a hard-coded IP literal, so that
changing a node's IP requires editing only the registry.

#### Scenario: extraHosts reflects the registry IP

- **WHEN** `flake.nebulaNodes.durer` is `192.168.100.12`
- **THEN** durer's `networking.extraHosts` SHALL contain `192.168.100.12 durer`
  produced from that registry entry, with no separately maintained IP literal

### Requirement: Registry helper for consumers

The flake SHALL expose a `self.lib.nebulaHosts` helper that folds `flake.nebulaNodes`
into a list usable by downstream consumers (such as the tmux host picker), so those
consumers never restate node names or IPs.

#### Scenario: Helper enumerates the registry

- **WHEN** `self.lib.nebulaHosts` is evaluated
- **THEN** it SHALL yield one entry per `flake.nebulaNodes` node carrying that node's
  name and overlay IP
