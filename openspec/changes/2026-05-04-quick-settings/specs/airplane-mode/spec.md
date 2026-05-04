# Airplane Mode

## ADDED Requirements

### Requirement: airplane-mode-toggle

The panel SHALL display a toggle button for airplane mode.

#### Scenario: enable airplane mode

GIVEN airplane mode is off
WHEN the user clicks the airplane mode toggle
THEN all radios SHALL be blocked via `rfkill block all`

#### Scenario: disable airplane mode

GIVEN airplane mode is on
WHEN the user clicks the airplane mode toggle
THEN all radios SHALL be unblocked via `rfkill unblock all`

#### Scenario: toggle reflects state

WHEN the panel opens
THEN the airplane mode toggle SHALL reflect whether any radios are currently blocked
