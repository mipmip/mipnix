# WiFi Status

## ADDED Requirements

### Requirement: wifi-icon

The bar SHALL display an icon reflecting the current wifi connection state.

#### Scenario: wifi connected

WHEN wifi is connected to a network
THEN the bar SHALL display a wifi icon corresponding to the signal strength

#### Scenario: wifi disconnected

WHEN wifi is not connected
THEN the bar SHALL display a disconnected wifi icon

### Requirement: wifi-visibility

The wifi icon SHALL only be visible when a wifi device is available.

#### Scenario: no wifi device

WHEN the system has no wifi device
THEN the wifi icon SHALL NOT be displayed

### Requirement: wifi-position

The wifi icon SHALL be positioned in the end section of the bar, left of the battery icon.

#### Scenario: layout order

WHEN the bar is rendered
THEN the end section SHALL show wifi icon before battery icon
