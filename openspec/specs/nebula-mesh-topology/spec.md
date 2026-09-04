# nebula-mesh-topology Specification

## Purpose
TBD - created by archiving change add-durer-second-lighthouse. Update Purpose after archive.

## Requirements

### Requirement: Single-source lighthouse registry

The nebula mesh configuration SHALL declare its set of lighthouses in one place via
a `mipnix.nebula.lighthouses` option: an attribute set mapping each lighthouse's
nebula VPN IP to its underlay endpoint in `"host:port"` form. Adding or removing a
lighthouse SHALL require editing only this registry.

#### Scenario: Registry lists both lighthouses

- **WHEN** `mipnix.nebula.lighthouses` is set to
  `{ "192.168.100.1" = "vaultwarden.tools.technative.cloud:4242"; "192.168.100.12" = "nuremberg.pimsnel.com:4242"; }`
- **THEN** every node's `services.nebula.networks.mesh.staticHostMap` SHALL contain
  `"192.168.100.1" = [ "vaultwarden.tools.technative.cloud:4242" ]` and
  `"192.168.100.12" = [ "nuremberg.pimsnel.com:4242" ]`

#### Scenario: Adding a lighthouse is a one-line registry edit

- **WHEN** a new `"<ip>" = "<host:port>"` entry is added to
  `mipnix.nebula.lighthouses`
- **THEN** all nodes SHALL pick up the new lighthouse in their static host map and
  (for non-lighthouse nodes) their lighthouse list, with no other per-host changes

### Requirement: Per-host lighthouse role flag

A host SHALL declare whether it acts as a lighthouse via a per-host
`mipnix.nebula.isLighthouse` boolean option that defaults to `false`. Non-lighthouse
nodes SHALL require no nebula-topology configuration beyond importing the shared
nebula module.

#### Scenario: durer is a lighthouse

- **WHEN** `mipnix.nebula.isLighthouse = true` is set on durer
- **THEN** durer's `services.nebula.networks.mesh.isLighthouse` SHALL be `true`

#### Scenario: A normal node needs no topology config

- **WHEN** a host imports the shared nebula module and does not set
  `mipnix.nebula.isLighthouse`
- **THEN** its `services.nebula.networks.mesh.isLighthouse` SHALL be `false`

### Requirement: Derived per-node lighthouse list

The shared nebula module SHALL derive each node's `lighthouses`
(nebula `lighthouse.hosts`) from the registry and the node's role. A lighthouse SHALL
advertise an empty lighthouse list; a non-lighthouse node SHALL list every lighthouse
VPN IP in the registry.

#### Scenario: Lighthouse advertises empty hosts

- **WHEN** a node has `mipnix.nebula.isLighthouse = true`
- **THEN** its `services.nebula.networks.mesh.lighthouses` SHALL be `[]`

#### Scenario: Normal node lists all lighthouses

- **WHEN** a node has `mipnix.nebula.isLighthouse = false` and the registry contains
  `192.168.100.1` and `192.168.100.12`
- **THEN** its `services.nebula.networks.mesh.lighthouses` SHALL contain both
  `192.168.100.1` and `192.168.100.12`

### Requirement: Every node maps every lighthouse

The shared nebula module SHALL set each node's `staticHostMap` to contain an entry
for every lighthouse in the registry, so any node can reach any lighthouse's underlay
endpoint. A lighthouse retaining its own registry entry in its static host map SHALL
be permitted (it is inert, since a node does not dial itself).

#### Scenario: Static host map covers all lighthouses on every node

- **WHEN** the registry contains `192.168.100.1` and `192.168.100.12`
- **THEN** both a lighthouse node and a non-lighthouse node SHALL have
  `staticHostMap` entries for `192.168.100.1` and `192.168.100.12`

### Requirement: Unreachable lighthouses remain listed for failover

A lighthouse that is temporarily unreachable SHALL remain in the registry so that
nodes fail over to the remaining lighthouse(s) and automatically resume using it once
it is reachable again, without a configuration change.

#### Scenario: Technative lighthouse stays listed while down

- **WHEN** the technative lighthouse `192.168.100.1` is unreachable
- **THEN** it SHALL remain in `mipnix.nebula.lighthouses` and nodes SHALL discover
  peers via the reachable durer lighthouse `192.168.100.12`

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

### Requirement: Registry helper for consumers

The flake SHALL expose a `self.lib.nebulaHosts` helper that folds `flake.nebulaNodes`
into a list usable by downstream consumers (such as the tmux host picker), so those
consumers never restate node names or IPs.

#### Scenario: Helper enumerates the registry

- **WHEN** `self.lib.nebulaHosts` is evaluated
- **THEN** it SHALL yield one entry per `flake.nebulaNodes` node carrying that node's
  name and overlay IP
