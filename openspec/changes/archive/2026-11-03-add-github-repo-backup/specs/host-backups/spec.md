## MODIFIED Requirements

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

#### Scenario: dapperehaan datasets

- **WHEN** dapperehaan backups run
- **THEN** `/home/pim/Work` (keep hourly 24, daily 7, weekly 5, monthly 12,
  yearly unlimited) and `/var/lib/hip-backup/repos` (keep daily 7, weekly 5,
  monthly 12, yearly unlimited) are each backed up to their own repository
