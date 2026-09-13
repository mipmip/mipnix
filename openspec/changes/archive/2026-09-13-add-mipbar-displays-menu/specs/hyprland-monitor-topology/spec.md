# Hyprland Monitor Topology

## RENAMED Requirements

- FROM: `### Requirement: coexist-with-nwg-displays`
- TO: `### Requirement: static-config-owns-no-dynamic-binding`

## MODIFIED Requirements

### Requirement: static-config-owns-no-dynamic-binding

The runtime workspace→monitor binding SHALL remain correct regardless of what
`monitors.conf` and `workspaces.conf` contain. Static configuration owns monitor
geometry; the runtime reconciliation owns the workspace→monitor binding. No desktop
tool writes either file — they are installed read-only from the Nix store, so any
tool that saves by writing them cannot work on this system.

#### Scenario: workspaces.conf regenerated with a stale connector name

- **WHEN** `workspaces.conf` pins workspaces 1–7 to a connector name that does not match
  the currently connected external monitor
- **THEN** the runtime reconciliation SHALL still place workspaces 1–7 on the connected
  external monitor

#### Scenario: runtime monitor geometry change does not move workspaces

- **WHEN** a monitor's resolution, scale, or position is changed at runtime
- **THEN** the workspace→monitor binding SHALL be unaffected

#### Scenario: configuration files are not writable from the desktop

- **WHEN** a desktop tool attempts to persist monitor geometry by writing
  `monitors.conf` or `workspaces.conf`
- **THEN** the write SHALL fail, because both are read-only Nix store symlinks
- **AND** monitor geometry SHALL be changed only by editing the declarative
  configuration in the repository and rebuilding
