## MODIFIED Requirements

### Requirement: Backup and sync unit state is collected

node-exporter SHALL report the state of every `restic-backups-*`,
`hip-repo-backup`, `syncthing` and `nix-gc` unit on its host, and the last
trigger time of their timers.

#### Scenario: Failed backup

- **WHEN** a restic backup or `hip-repo-backup` run ends in the failed state
- **THEN** that unit shows as failed in Prometheus for that host

#### Scenario: Timer stopped firing

- **WHEN** a backup timer has not fired for longer than its interval
- **THEN** its last trigger time in Prometheus shows how long ago it ran

#### Scenario: Garbage collection

- **WHEN** a host has `nix.gc` enabled and its timer fires
- **THEN** the last trigger time of `nix-gc.timer` is in Prometheus
