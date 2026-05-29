## ADDED Requirements

### Requirement: Multiple OpenClaw instances on single guest
The clawone guest SHALL support running multiple independent OpenClaw gateway instances, each with its own system user, state directory, config, and network port.

#### Scenario: Two instances run concurrently
- **WHEN** the clawone guest boots
- **THEN** both `openclaw-gateway` (port 18789) and `openclaw-gateway-janine` (port 18790) SHALL be in `active (running)` state

#### Scenario: Instances have separate state
- **WHEN** both instances are running
- **THEN** `/var/lib/openclaw/` and `/var/lib/openclaw-janine/` SHALL contain independent configs, auth tokens, and logs

### Requirement: Second instance for Janine
The clawone guest SHALL run an OpenClaw gateway instance for Janine with system user `openclaw-janine`, state dir `/var/lib/openclaw-janine/`, and gateway port 18790.

#### Scenario: Janine's Matrix bot connects
- **WHEN** the `openclaw-gateway-janine` service starts
- **THEN** it SHALL connect to nuremberg.pimsnel.com as `@openclaw-janine:pimsnel.com`

#### Scenario: Janine's assistant responds in Dutch
- **WHEN** Janine sends a message in Matrix
- **THEN** the assistant SHALL respond in Dutch by default

### Requirement: CLI wrapper scripts for each instance
The guest SHALL provide wrapper scripts `openclaw-pim` and `openclaw-janine` that set the correct environment variables for each instance.

#### Scenario: CLI targets correct instance
- **WHEN** `openclaw-janine config list` is run
- **THEN** it SHALL show Janine's config from `/var/lib/openclaw-janine/openclaw.json`

#### Scenario: Pim CLI targets pim instance
- **WHEN** `openclaw-pim config list` is run
- **THEN** it SHALL show Pim's config from `/var/lib/openclaw/openclaw.json`
