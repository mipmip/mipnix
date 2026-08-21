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

