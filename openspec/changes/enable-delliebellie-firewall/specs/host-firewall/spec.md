## ADDED Requirements

### Requirement: Per-host firewall state

Whether a host runs the NixOS firewall SHALL be declared in that host's own
configuration. Enabling the firewall on one host SHALL NOT change the state on
any other host.

#### Scenario: One host enabled

- **WHEN** delliebellie sets `networking.firewall.enable = true`
- **THEN** delliebellie's firewall SHALL be enabled after the next switch
- **AND** every other host's firewall state SHALL be unchanged

#### Scenario: A host that keeps the firewall off

- **WHEN** a host sets `networking.firewall.enable = false`
- **THEN** this change SHALL NOT alter that host's firewall state

### Requirement: Mesh services survive the firewall

A host that runs the firewall SHALL keep the services that listen on the mesh
interface reachable to mesh peers. The allowance SHALL be scoped to the mesh
interface and SHALL NOT open the service on every interface.

Services that the NixOS modules already open, such as SSH and mDNS, SHALL keep
working without restating their ports in the host configuration.

#### Scenario: A mesh peer connects

- **WHEN** a host with the firewall enabled receives a pool connection over
  the mesh interface
- **THEN** the connection SHALL be accepted on the port that service listens on

#### Scenario: The host joins an untrusted network

- **WHEN** the same host connects to a network that is not the mesh
- **THEN** the mesh-scoped service SHALL NOT be reachable on that network's
  interface

#### Scenario: SSH and mDNS keep working

- **WHEN** the firewall is enabled on a host that runs sshd and avahi
- **THEN** TCP 22 and UDP 5353 SHALL stay open
