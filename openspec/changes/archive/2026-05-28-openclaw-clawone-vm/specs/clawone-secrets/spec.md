## ADDED Requirements

### Requirement: Pre-generated SSH host key for clawone
An ed25519 SSH host key pair SHALL be pre-generated for the clawone guest. The public key SHALL be registered in `secrets/secrets.nix` as an agenix identity. The private key SHALL be deployed to the guest so agenix can use it for decryption.

#### Scenario: clawone identity in secrets.nix
- **WHEN** `secrets/secrets.nix` is evaluated
- **THEN** a `clawone` variable SHALL be defined with the guest's ed25519 public key

#### Scenario: Host key available inside guest
- **WHEN** the clawone guest boots
- **THEN** the SSH host private key SHALL be present at the expected path for agenix decryption

### Requirement: Matrix bot password encrypted with agenix
The Matrix bot password SHALL be stored as `secrets/matrix-openclaw-password.age`, encrypted to the pim user key and the clawone host key. The guest's agenix configuration SHALL decrypt it to a file path accessible by the OpenClaw gateway.

#### Scenario: Secret encrypted for correct identities
- **WHEN** `secrets/secrets.nix` is evaluated
- **THEN** `matrix-openclaw-password.age` SHALL have publicKeys including `pim` and `clawone`

#### Scenario: Secret decrypted inside guest
- **WHEN** the clawone guest boots with its SSH host key
- **THEN** the Matrix bot password SHALL be decrypted and available at the configured agenix path

#### Scenario: OpenClaw reads the password
- **WHEN** the openclaw-gateway service starts
- **THEN** it SHALL read the Matrix bot password from the agenix-decrypted file path
