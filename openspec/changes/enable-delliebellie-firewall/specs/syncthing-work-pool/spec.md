## ADDED Requirements

### Requirement: Firewall-compatible transport

Every member SHALL allow inbound pool transport on the mesh interface as part
of the pool configuration. Enabling the host firewall SHALL NOT stop a member
from syncing. The allowance SHALL be scoped to the mesh interface and SHALL NOT
open the port on every interface.

#### Scenario: A member enables its firewall

- **WHEN** a member enables the host firewall and a peer dials it over the mesh
- **THEN** the connection SHALL be accepted on TCP 22000
- **AND** the member SHALL sync with that peer

#### Scenario: A new member inherits the allowance

- **WHEN** a host declares pool membership
- **THEN** it SHALL receive the mesh-interface allowance without a per-host
  edit

#### Scenario: No global opening

- **WHEN** a member is connected to a network that is not the mesh
- **THEN** TCP 22000 SHALL NOT be reachable on that network's interface
