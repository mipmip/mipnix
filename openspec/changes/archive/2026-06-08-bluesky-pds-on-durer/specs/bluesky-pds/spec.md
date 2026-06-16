## ADDED Requirements

### Requirement: PDS service enabled on durer
The system SHALL run the Bluesky PDS on durer using `services.bluesky-pds`.

#### Scenario: Service starts successfully
- **WHEN** durer boots or `nixos-rebuild switch` completes
- **THEN** the `bluesky-pds` systemd service SHALL be running and listening on port 3000

### Requirement: PDS hostname identity
The PDS SHALL use `pimsnel.com` as its hostname, enabling the handle `@pimsnel.com`.

#### Scenario: PDS identifies as pimsnel.com
- **WHEN** the PDS is running
- **THEN** `PDS_HOSTNAME` SHALL be set to `pimsnel.com`

### Requirement: PDS secrets via agenix
The PDS secrets SHALL be managed via agenix and loaded from an encrypted environment file.

#### Scenario: Secrets available at runtime
- **WHEN** the PDS service starts
- **THEN** it SHALL read `PDS_JWT_SECRET`, `PDS_ADMIN_PASSWORD`, and `PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX` from the agenix-decrypted environment file

### Requirement: PDS admin tooling
The `pdsadmin` CLI tool SHALL be available on durer for account management.

#### Scenario: Admin creates account
- **WHEN** an administrator runs `pdsadmin account create`
- **THEN** a new account SHALL be created on the PDS

### Requirement: PDS data storage
The PDS SHALL store its data (SQLite database and blobs) in `/var/lib/pds/`.

#### Scenario: Data persists across restarts
- **WHEN** the PDS service restarts
- **THEN** all accounts, posts, and blobs SHALL be preserved
