## ADDED Requirements

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
