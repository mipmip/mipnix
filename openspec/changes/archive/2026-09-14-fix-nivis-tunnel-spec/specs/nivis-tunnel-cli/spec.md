## MODIFIED Requirements

### Requirement: nivis-tunnel Present In The Infrastructure Toolchain
The system SHALL install the orchestrator command of nivis-tunnel on every host
that carries the devbox role, alongside the other infrastructure tools. It SHALL
be invocable as `nivis-tunnel`, which is the name upstream's own documentation
uses for every subcommand.

#### Scenario: Invoking it on a devbox host
- **WHEN** a user on a host with the devbox role runs `nivis-tunnel` in any shell
- **THEN** the command SHALL resolve without a `nix run` and without a manual
  PATH entry

#### Scenario: A documented invocation works verbatim
- **WHEN** a user runs a command copied from upstream's README, such as
  `nivis-tunnel connect <id>` used as an ssh `ProxyCommand`
- **THEN** it SHALL reach the same program, with its arguments unchanged

#### Scenario: Host without the devbox role
- **WHEN** a host does not carry the devbox role
- **THEN** `nivis-tunnel` SHALL NOT be installed on it

### Requirement: The Generic Name Is Not Claimed
The system SHALL NOT place a command named `tunnel` on the system PATH, whatever
upstream chooses to call its binaries. The name is too generic to claim
system-wide for one tool, so if a future revision publishes it under that name
again, the system SHALL rename it rather than install it as published.

#### Scenario: What the toolchain adds
- **WHEN** the commands a devbox host gains from this change are inspected
- **THEN** `nivis-tunnel` SHALL be among them
- **AND** `tunnel` SHALL NOT be
