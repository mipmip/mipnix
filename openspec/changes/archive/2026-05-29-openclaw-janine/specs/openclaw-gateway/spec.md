## MODIFIED Requirements

### Requirement: Matrix channel configured as bot
OpenClaw SHALL be configured with a Matrix channel pointing at nuremberg.pimsnel.com using a dedicated bot user with password authentication.

#### Scenario: Bot connects to Matrix server
- **WHEN** the openclaw-gateway service starts
- **AND** the Matrix bot password is available in the openclaw config
- **THEN** OpenClaw SHALL connect to nuremberg.pimsnel.com as the bot user

#### Scenario: Bot responds to messages
- **WHEN** a user sends a message to the bot in a Matrix room
- **THEN** OpenClaw SHALL process the message and reply in the same room
