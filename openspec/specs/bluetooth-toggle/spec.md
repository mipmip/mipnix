# Bluetooth Toggle

## ADDED Requirements

### Requirement: bluetooth-on-off

The panel SHALL display a toggle button for bluetooth power state.

#### Scenario: turn bluetooth on

GIVEN bluetooth is off
WHEN the user clicks the bluetooth toggle
THEN the bluetooth adapter SHALL be powered on

#### Scenario: turn bluetooth off

GIVEN bluetooth is on
WHEN the user clicks the bluetooth toggle
THEN the bluetooth adapter SHALL be powered off

#### Scenario: toggle reflects state

WHEN the panel opens
THEN the bluetooth toggle SHALL reflect the current adapter power state

### Requirement: bluetooth-pair-button

The panel SHALL display a "Pair" button that opens the external bluetooth manager.

#### Scenario: open pairing tool

WHEN the user clicks the Pair button
THEN `blueman-manager` SHALL be launched
