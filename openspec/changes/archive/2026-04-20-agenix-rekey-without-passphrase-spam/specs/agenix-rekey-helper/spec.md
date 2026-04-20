## ADDED Requirements

### Requirement: Rekey command in RUNME.sh
The system SHALL provide a `rekey` command in RUNME.sh that re-encrypts all age files with a single passphrase prompt.

#### Scenario: Successful rekey
- **WHEN** user runs `./RUNME.sh rekey`
- **THEN** `ssh-to-age` prompts for the SSH passphrase once, a temporary age identity is created, `agenix --rekey -i <tmpfile>` runs against all age files, and the temp file is shredded

#### Scenario: ssh-to-age fails
- **WHEN** `ssh-to-age` fails to convert the key
- **THEN** the command exits with an error and no temp file remains on disk

### Requirement: Shared age identity helper
The system SHALL provide a `with_age_identity` function in RUNME.sh that creates a temporary age identity, runs a given operation, and cleans up afterwards.

#### Scenario: Normal operation
- **WHEN** `with_age_identity` is called with a callback
- **THEN** it creates a temp file, converts SSH key via `ssh-to-age`, sets `AGE_IDENTITY` to the temp path, executes the callback, and shreds the temp file on return

#### Scenario: Callback fails
- **WHEN** the callback function fails mid-execution
- **THEN** the temp file SHALL still be shredded via trap

### Requirement: new_nebula_node uses shared helper
The `new_nebula_node` function SHALL use `with_age_identity` for all `age --decrypt` calls instead of passing `-i ~/.ssh/id_ed25519` directly.

#### Scenario: Creating nebula certificates
- **WHEN** user runs `./RUNME.sh new_nebula_node`
- **THEN** the passphrase is prompted once (via `with_age_identity`), and all three decrypt operations (CA key, CA cert, existing cert scanning) use the temporary age identity
