# Mosh Server Access

## ADDED Requirements

### Requirement: mosh-udp-range-reachable

Hosts using `role-server` SHALL allow the mosh UDP session port range (60000–61000) through the firewall on the network path used to reach them, so mosh sessions can establish after the SSH bootstrap.

#### Scenario: firewall permits mosh UDP on the connection path

- **WHEN** a mosh client connects to a `role-server` host over the chosen path (Nebula mesh or public)
- **THEN** the host's firewall SHALL allow inbound UDP on the mosh session range on that path, and the mosh session SHALL establish rather than hang after the SSH handshake

#### Scenario: durer accepts mosh

- **WHEN** a mosh connection is made to `durer`
- **THEN** `durer`'s firewall SHALL permit the mosh UDP range on the path used (in addition to its existing `tcp 22/80/443` and `udp 4242` rules)

### Requirement: mosh-client-on-laptop

The `lego2` laptop environment SHALL include the mosh client so a mosh session can be initiated from the laptop.

#### Scenario: laptop can launch mosh

- **WHEN** the user runs `mosh` from the `lego2` laptop
- **THEN** the `mosh` client command SHALL be available on PATH

### Requirement: mosh-ssh-bootstrap-available

`role-server` hosts SHALL have SSH available for mosh's bootstrap (mosh launches its server over SSH before switching to UDP).

#### Scenario: SSH present for bootstrap

- **WHEN** a mosh client initiates a connection to a `role-server` host
- **THEN** SSH (`services.openssh`) SHALL be enabled on the host so mosh can start its server process

### Requirement: verified-lego2-to-durer-session

A mosh session from the `lego2` laptop to `durer` SHALL be demonstrably working as the acceptance criterion for this change.

#### Scenario: interactive session establishes

- **WHEN** the user runs mosh from `lego2` to `durer`
- **THEN** an interactive shell session SHALL establish over mosh (not merely the SSH bootstrap)

#### Scenario: session survives a network change

- **WHEN** an established `lego2`→`durer` mosh session experiences a brief network interruption or IP change
- **THEN** the session SHALL resume without being dropped (mosh's core roaming behavior)
