# host-backups Specification

## Purpose

Unattended, encrypted per-host backups of configured datasets to the piethein NAS
using `restic` over SFTP, with per-dataset retention and independently recoverable
restore credentials.
## Requirements
### Requirement: Backups run unattended to the piethein NAS over SFTP

The system SHALL back up configured host paths to the piethein NAS
(192.168.2.100) using `restic` over SFTP as the non-admin `resticbackup`
user, without any interactive input at runtime.

#### Scenario: Scheduled backup completes non-interactively

- **WHEN** a host's backup timer fires
- **THEN** restic connects via SFTP using the shared backup private key, unlocks
  the repository with the shared repo password, and creates a new snapshot without
  prompting for a password or host-key confirmation

#### Scenario: Host key is pinned

- **WHEN** restic opens the SSH/SFTP connection to piethein
- **THEN** piethein's host key is verified against a pinned known-hosts entry, and
  an unknown or changed host key SHALL cause the backup to fail rather than
  auto-accept

#### Scenario: resticbackup remains a non-admin user

- **WHEN** the backup authenticates to piethein
- **THEN** it uses only the SFTP subsystem and SHALL NOT require the `resticbackup`
  account to be a member of the Synology `administrators` group

### Requirement: One repository per host and dataset

Each backed-up dataset SHALL be stored in its own restic repository under the
chrooted share path `/ResticBackups/<host>-<dataset>`.

#### Scenario: Repository path layout

- **WHEN** a dataset named `<dataset>` on host `<host>` is backed up
- **THEN** its repository is `sftp:resticbackup@192.168.2.100:/ResticBackups/<host>-<dataset>`
  and does not share a repository with any other host or dataset

#### Scenario: Repositories are encrypted at rest

- **WHEN** a repository is created
- **THEN** it is initialized with the shared restic repository password so its
  contents are encrypted on the NAS

### Requirement: Hourly scheduling with per-dataset retention

Each dataset SHALL be backed up hourly and pruned according to a
retention policy defined per dataset.

#### Scenario: Hourly, resilient timers

- **WHEN** the backup timer is configured
- **THEN** it runs approximately hourly, is `Persistent` (catches up one missed run
  after downtime), applies a randomized delay to avoid all hosts hitting the NAS at
  once, and orders after network is online

#### Scenario: Retention is applied after each backup

- **WHEN** a backup finishes
- **THEN** `restic forget --prune` runs with that dataset's `--keep-*` policy so old
  snapshots are collapsed per the grandfather-father-son buckets defined for it

#### Scenario: secondbrain is kept forever

- **WHEN** the `cichorei-secondbrain` repository is pruned
- **THEN** its policy retains recent snapshots densely and keeps at least one snapshot
  per year indefinitely (no yearly cap), so historical notes remain recoverable

### Requirement: Databases are dumped to a consistent file before backup

Datasets backed by a live database SHALL be captured via a
dump-to-file step before restic runs, and the dump SHALL be removed afterward.

#### Scenario: voorzetramenshop PostgreSQL dump

- **WHEN** the durer voorzetramenshop backup runs
- **THEN** a `pg_dump` of the native `voorzetramenshop` PostgreSQL database is written
  to a dump file, restic backs up that file, and the file is deleted after the backup

#### Scenario: umami PostgreSQL (Docker) dump

- **WHEN** the durer umami backup runs
- **THEN** a `pg_dump` is taken from the `umami-db` Docker container to a dump file,
  restic backs up that file, and the file is deleted after the backup

### Requirement: Restore credentials are recoverable independently of the hosts

The shared backup private key and the restic repository password SHALL be
recoverable without access to any single backed-up host.

#### Scenario: A host is lost

- **WHEN** a backup host is destroyed and must be restored from scratch
- **THEN** the repo password and backup key are available from an offline/independent
  location (not only from the host's own agenix-decrypted secrets), so its
  repositories can be decrypted and restored

### Requirement: Configured backup targets

The system SHALL back up the following datasets with the stated retention.

#### Scenario: cichorei datasets

- **WHEN** cichorei backups run
- **THEN** `/home/pim/.claude` (keep hourly 24, daily 7), `/home/pim/secondbrain`
  (keep hourly 24, daily 7, weekly 5, monthly 12, yearly unlimited), and
  `/home/pim/.ssh` (keep hourly 24, daily 7) are each backed up to their own repository

#### Scenario: hurry datasets

- **WHEN** hurry backups run
- **THEN** `/var/lib/backups/vaultwarden` (keep hourly 24, daily 14, monthly 6) and
  `/home/pim/.ssh` (keep hourly 24, daily 7) are each backed up to their own repository

#### Scenario: durer datasets

- **WHEN** durer backups run
- **THEN** the voorzetramenshop DB dump (keep hourly 24, daily 14, monthly 6), the umami
  DB dump (keep hourly 24, daily 7), and `/home/pim/.ssh` (keep hourly 24, daily 7) are
  each backed up to their own repository

### Requirement: Datasets are enumerable as a flake-level registry

The set of every host's configured `mipnix.backup.piethein.datasets` SHALL be
exposed as an aggregated flake-level registry mapping each repository to its
`(host, dataset, repository path)`, so an off-host consumer (such as the Backrest
console on dapperehaan) can enumerate all repositories without reading each host's
private configuration or decrypting any secret. Adding a dataset on a host SHALL make
it appear in the registry with no separate restatement of its name or path.

#### Scenario: Registry lists every host's datasets

- **WHEN** the flake is evaluated
- **THEN** the registry SHALL contain an entry for each dataset declared across hosts
  (e.g. `cichorei-documents`, `zonnehoed-janine`, `hurry-vaultwarden`,
  `durer-voorzetramenshop`), each resolving to its
  `sftp:resticbackup@192.168.2.100:/ResticBackups/<host>-<dataset>` repository

#### Scenario: Relay-only and non-backup hosts contribute nothing

- **WHEN** a host has no datasets (e.g. relay-only `harry`) or does not back up
- **THEN** it SHALL contribute no entries to the registry

#### Scenario: Adding a dataset is a single-site edit

- **WHEN** a new dataset is added to a host's `mipnix.backup.piethein.datasets`
- **THEN** the registry SHALL include it on the next evaluation with no other edit,
  and its repository name/path SHALL be derived, not restated

