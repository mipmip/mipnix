## ADDED Requirements

### Requirement: nix-openclaw flake input available
The flake SHALL include `nix-openclaw` as an input, providing the Home Manager module for OpenClaw.

#### Scenario: Flake input resolves
- **WHEN** the flake is evaluated
- **THEN** `inputs.nix-openclaw` SHALL resolve to the nix-openclaw flake

### Requirement: OpenClaw gateway runs as Home Manager service on clawone
The clawone guest SHALL have Home Manager configured with `programs.openclaw` enabled and the gateway systemd user service running.

#### Scenario: Gateway service active
- **WHEN** the clawone guest is running
- **THEN** `systemctl --user status openclaw-gateway` SHALL report `active (running)`

#### Scenario: Gateway survives reboot
- **WHEN** the clawone guest is restarted
- **THEN** the openclaw-gateway user service SHALL start automatically

### Requirement: OpenAI configured as AI provider
The OpenClaw gateway SHALL be configured to use OpenAI as its AI provider. Authentication SHALL be performed via `openclaw login` and the session token SHALL persist across reboots in the microvm's persistent volume.

#### Scenario: OpenAI provider responds after login
- **WHEN** `openclaw login` has been completed inside the guest
- **AND** a message is sent to OpenClaw
- **THEN** OpenClaw SHALL route the request to the OpenAI API and return a response

#### Scenario: Session persists across reboot
- **WHEN** `openclaw login` has been completed
- **AND** the guest VM is restarted
- **THEN** OpenClaw SHALL still be authenticated with OpenAI without requiring re-login

### Requirement: Matrix channel configured as bot
OpenClaw SHALL be configured with a Matrix channel pointing at nuremberg.pimnsnel.com using a dedicated bot user with password authentication.

#### Scenario: Bot connects to Matrix server
- **WHEN** the openclaw-gateway service starts
- **AND** the Matrix bot password is available via agenix
- **THEN** OpenClaw SHALL connect to nuremberg.pimnsnel.com as the bot user

#### Scenario: Bot responds to messages
- **WHEN** a user sends a message to the bot in a Matrix room
- **THEN** OpenClaw SHALL process the message and reply in the same room

### Requirement: Workspace documents present
The OpenClaw configuration SHALL include the required workspace documents: AGENTS.md, SOUL.md, and TOOLS.md.

#### Scenario: Gateway starts with workspace documents
- **WHEN** the openclaw-gateway service starts
- **THEN** the workspace documents directory SHALL contain AGENTS.md, SOUL.md, and TOOLS.md
- **AND** the gateway SHALL not report missing workspace template errors
