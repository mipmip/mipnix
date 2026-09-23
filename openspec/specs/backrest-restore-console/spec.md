# backrest-restore-console Specification

## Purpose
TBD - created by archiving change add-backrest-restore-console. Update Purpose after archive.
## Requirements
### Requirement: Nebula-only Backrest web console

dapperehaan SHALL run Backrest as a hardened systemd service bound to its nebula IP
`192.168.100.2` on port `9898`, reachable only over the mesh. The service SHALL NOT
listen on any public or LAN-wide interface, and restic SHALL be pinned to the Nix
store package rather than downloaded at runtime.

#### Scenario: Reachable over nebula, not publicly

- **WHEN** the Backrest service is running
- **THEN** it SHALL be reachable at `http://dapperehaan:9898` from a nebula host, and
  SHALL NOT be bound to `0.0.0.0` or exposed on the public internet

#### Scenario: Restic binary is pinned

- **WHEN** Backrest invokes restic
- **THEN** it SHALL use the pinned `pkgs.restic` (via `BACKREST_RESTIC_COMMAND`) and
  SHALL NOT download its own restic binary

### Requirement: Authenticated access

Backrest SHALL require login before any repository, snapshot, or restore action is
available. Credentials SHALL be provided from an agenix secret and SHALL NOT appear
as a literal in any Nix option or the generated config in the store.

#### Scenario: Anonymous request is rejected

- **WHEN** an unauthenticated client requests the Backrest UI or API
- **THEN** access SHALL be denied until valid credentials are supplied

#### Scenario: Credentials come from a secret

- **WHEN** the service starts
- **THEN** the login credential SHALL be read from the `backrest-auth` agenix secret,
  not from a world-readable store path

### Requirement: Browse and restore across all repositories

Backrest SHALL present every piethein restic repository so snapshots can be browsed
and files or whole snapshots restored, unlocking each repository with the shared
`restic-repo-pw` over SFTP authenticated by the shared `restic-ssh-key`, with
piethein's host key pinned.

#### Scenario: Every repository is listed

- **WHEN** an authenticated user opens Backrest
- **THEN** every repository from the dataset registry (e.g. `cichorei-documents`,
  `zonnehoed-janine`, `hurry-vaultwarden`, `durer-voorzetramenshop`) SHALL be present
  and its snapshots browsable

#### Scenario: Restore a file from a snapshot

- **WHEN** the user selects a snapshot and requests a restore
- **THEN** Backrest SHALL restore the chosen paths using restic against that repo

#### Scenario: Host key is pinned

- **WHEN** Backrest opens the SFTP connection to piethein
- **THEN** piethein's host key SHALL be verified against a pinned known-hosts entry,
  and an unknown or changed key SHALL fail rather than auto-accept

### Requirement: No backup scheduling

Backrest SHALL be configured for browse/restore only: it SHALL register repositories
without any backup plan or schedule, so it never creates snapshots that would collide
with the existing NixOS restic timers.

#### Scenario: No plans are defined

- **WHEN** the generated Backrest config is loaded
- **THEN** it SHALL contain the repositories but zero backup plans, and Backrest SHALL
  not run any scheduled backup

#### Scenario: Existing timers remain the source of backups

- **WHEN** a scheduled NixOS restic timer fires on any host
- **THEN** it SHALL create snapshots exactly as before, uninfluenced by Backrest

