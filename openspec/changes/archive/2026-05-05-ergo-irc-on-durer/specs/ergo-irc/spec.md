## ADDED Requirements

### Requirement: Ergo IRC server enabled on durer
The system SHALL run the Ergo IRC daemon on durer with `services.ergochat` enabled and configured via `services.ergochat.settings`.

#### Scenario: Service starts successfully
- **WHEN** durer boots or `nixos-rebuild switch` completes
- **THEN** the `ergochat` systemd service SHALL be running and listening on port 6697

### Requirement: TLS-only listener on port 6697
The system SHALL expose a single IRC listener on port 6697 with TLS using ACME-provisioned certificates from `/var/lib/acme/nuremberg.pimsnel.com/`. Plaintext IRC listeners SHALL be disabled.

#### Scenario: Client connects with TLS
- **WHEN** a client connects to `nuremberg.pimsnel.com:6697` with TLS
- **THEN** the server SHALL present a valid Let's Encrypt certificate for `nuremberg.pimsnel.com`

#### Scenario: No plaintext listener
- **WHEN** a client attempts to connect on port 6667 (plaintext)
- **THEN** the connection SHALL be refused (port not open)

### Requirement: Server identity
The server SHALL identify as `server.name = "nuremberg.pimsnel.com"` with a configurable network name.

#### Scenario: Server announces identity
- **WHEN** a client connects and completes registration
- **THEN** the server SHALL report its name as `nuremberg.pimsnel.com`

### Requirement: SASL authentication required
The server SHALL require SASL authentication for all connections. Unauthenticated users SHALL NOT be able to join channels or send messages.

#### Scenario: Authenticated user connects
- **WHEN** a user connects with valid SASL PLAIN credentials
- **THEN** the user SHALL be logged in and able to join channels

#### Scenario: Unauthenticated user rejected
- **WHEN** a user connects without SASL authentication
- **THEN** the server SHALL reject the connection before allowing any channel activity

### Requirement: Admin-only account registration
Account self-registration SHALL be disabled. Only IRC operators SHALL be able to create accounts using `/NS SAREGISTER`.

#### Scenario: User attempts self-registration
- **WHEN** an unauthenticated user attempts `/NS REGISTER`
- **THEN** the server SHALL reject the registration

#### Scenario: Operator creates account
- **WHEN** an authenticated operator runs `/NS SAREGISTER <username> <password>`
- **THEN** a new account SHALL be created with the given credentials

### Requirement: IRC operator configured
The server SHALL have at least one operator account configured with a bcrypt-hashed password in the Nix configuration.

#### Scenario: Operator authenticates
- **WHEN** a logged-in user runs `/OPER <opername> <password>`
- **THEN** the user SHALL gain operator privileges if the password matches the configured bcrypt hash

### Requirement: Always-on bouncer mode
The server SHALL enable always-on multiclient mode by default (opt-out). Connected accounts SHALL persist across disconnects and buffer messages for replay.

#### Scenario: User disconnects and reconnects
- **WHEN** a user disconnects and later reconnects with the same account
- **THEN** the server SHALL replay messages received during the disconnection

#### Scenario: User opts out of always-on
- **WHEN** a user runs `/NS SET always-on false`
- **THEN** the user's session SHALL end on disconnect (no message buffering)

### Requirement: Firewall allows IRC traffic
Port 6697/tcp SHALL be open in the durer firewall configuration.

#### Scenario: External client reaches IRC port
- **WHEN** a client from the internet connects to `nuremberg.pimsnel.com:6697`
- **THEN** the connection SHALL reach the Ergo service

### Requirement: Certificate reload on renewal
The Ergo service SHALL reload TLS certificates when ACME renews them, without requiring a full service restart.

#### Scenario: ACME certificate renews
- **WHEN** Let's Encrypt issues a new certificate
- **THEN** the ACME renewal hook SHALL send SIGHUP to the Ergo service and Ergo SHALL serve the new certificate
