# Spec Delta

Schema: tinychange (https://github.com/speclib/openspec-tinychange-schema)

## MODIFIED Requirements

### Requirement: The v3 database is backed up
durer SHALL back up the `studio_mint_v3` database as its own restic dataset `durer-studio-mint-v3`, following the existing host-backups rules.

#### Scenario: Hourly dump
- **WHEN** the backup timer for `durer-studio-mint-v3` fires
- **THEN** a `pg_dump` of `studio_mint_v3` is written, snapshotted to `/ResticBackups/durer-studio-mint-v3`, and removed from disk afterwards

#### Scenario: Uploads are in the same snapshot
- **WHEN** the backup timer for `durer-studio-mint-v3` fires
- **THEN** the snapshot also contains `/var/lib/studio-mint-v3/uploads`, so images and customer photos can be restored together with the database that refers to them
