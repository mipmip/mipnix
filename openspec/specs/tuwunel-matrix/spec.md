### Requirement: Tuwunel Matrix homeserver enabled on durer
The system SHALL run the Tuwunel Matrix homeserver on durer using `services.matrix-tuwunel`.

#### Scenario: Service starts successfully
- **WHEN** durer boots or `nixos-rebuild switch` completes
- **THEN** the `tuwunel` systemd service SHALL be running and listening on localhost port 6167

### Requirement: Server identity
The server SHALL use `server_name = "nuremberg.pimsnel.com"`.

#### Scenario: User IDs use correct domain
- **WHEN** a user account is created
- **THEN** the user ID SHALL be in the format `@username:nuremberg.pimsnel.com`

### Requirement: Registration disabled
Open registration SHALL be disabled. Only server administrators SHALL be able to create accounts.

#### Scenario: Client attempts registration
- **WHEN** a Matrix client attempts to register a new account via the registration API
- **THEN** the server SHALL reject the registration

#### Scenario: Admin creates account
- **WHEN** an administrator uses the Tuwunel CLI on the server to create an account
- **THEN** the account SHALL be created successfully

### Requirement: End-to-end encryption enabled
The server SHALL allow creation of encrypted rooms (`allow_encryption = true`).

#### Scenario: Client creates encrypted room
- **WHEN** a client creates a room with encryption enabled
- **THEN** the server SHALL accept the room creation with encryption

### Requirement: Federation disabled
The server SHALL NOT federate with other Matrix homeservers (`allow_federation = false`).

#### Scenario: No outbound federation
- **WHEN** the server is running
- **THEN** it SHALL NOT attempt to communicate with other Matrix homeservers

### Requirement: Trusted servers empty
The `trusted_servers` list SHALL be empty since federation is disabled.

#### Scenario: No trusted servers configured
- **WHEN** the server configuration is loaded
- **THEN** the trusted servers list SHALL be empty
