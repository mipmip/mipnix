# Spec Delta

## Purpose

Lets a mipnix host join the external LUWOPI Nebula network as a client, so it
can reach the group's shared services without exposing anything of its own.

## ADDED Requirements

### Requirement: Separate network instance

The includable SHALL configure the LUWOPI network as its own
`services.nebula.networks.luwopi` instance, with the group's CA, and SHALL NOT
reuse or alter the existing mipnix `mesh` network.

#### Scenario: Member runs both networks

- **WHEN** a host enables the includable while also running the mipnix mesh
- **THEN** it SHALL have both a `nebula.mesh` interface and a `nebula.luwopi`
  interface, each with its own CA committed in its configuration

#### Scenario: Mesh is untouched

- **WHEN** the includable is enabled
- **THEN** the mipnix mesh's CA, lighthouses and firewall rules SHALL remain
  exactly as they were

### Requirement: Per-host identity

Each member SHALL use its own certificate and key issued by the LUWOPI group
administrator. The includable SHALL load `nebula-luwopi-<host>.crt.age` and
`nebula-luwopi-<host>.key.age` for the host it runs on, and two hosts SHALL NOT
share one identity.

#### Scenario: Identity follows the host name

- **WHEN** the includable is enabled on delliebellie
- **THEN** the network SHALL use the certificate and key files derived from
  `delliebellie`

#### Scenario: A second member has a distinct identity

- **WHEN** the includable is enabled on peterspav
- **THEN** peterspav SHALL use a certificate with its own name and overlay
  address, not delliebellie's `post` certificate

### Requirement: Membership is opt-in

Importing the includable SHALL NOT start the network by itself. A host SHALL
join only by setting `mipnix.nebula.luwopi.enable = true`.

#### Scenario: Import without enabling

- **WHEN** a host imports the includable but leaves the enable option unset
- **THEN** no `nebula@luwopi` service SHALL run on that host

#### Scenario: Enabled host joins

- **WHEN** a host sets `mipnix.nebula.luwopi.enable = true`
- **THEN** the `nebula@luwopi` service SHALL start and report to the group
  lighthouse

### Requirement: Lighthouse discovery

The network SHALL use `192.168.200.1` as its only lighthouse, reached through
the static underlay endpoint `54.93.81.45:4242`. A member SHALL NOT act as a
lighthouse or relay.

#### Scenario: Member finds the lighthouse

- **WHEN** the network starts
- **THEN** its configuration SHALL list `192.168.200.1` as lighthouse and map
  that address to `54.93.81.45:4242`

### Requirement: Outbound-only firewall posture

A member SHALL accept no inbound traffic from the LUWOPI network, and SHALL be
able to open connections to any group service. The NixOS firewall SHALL open no
port on the `nebula.luwopi` interface.

#### Scenario: Group services are reachable

- **WHEN** a member opens a connection to `192.168.200.2` on a served port
- **THEN** the connection SHALL succeed and its replies SHALL return without an
  inbound rule

#### Scenario: The member is not exposed

- **WHEN** another LUWOPI member tries to open a connection to a port on the
  member's `nebula.luwopi` address
- **THEN** the connection SHALL be refused

### Requirement: Limited secret recipients

The LUWOPI CA certificate, member certificate and member key SHALL be encrypted
only to `pim` and the member hosts that need them.

#### Scenario: Unrelated host cannot decrypt

- **WHEN** a host outside the recipient set attempts to decrypt a
  `nebula-luwopi-*` secret
- **THEN** decryption SHALL fail

#### Scenario: Both member hosts can decrypt

- **WHEN** delliebellie or peterspav decrypts the LUWOPI CA certificate
- **THEN** decryption SHALL succeed
