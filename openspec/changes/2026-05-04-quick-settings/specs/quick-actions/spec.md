# Quick Actions

## ADDED Requirements

### Requirement: lock-action

The panel SHALL display a Lock button.

#### Scenario: lock screen

WHEN the user clicks the Lock button
THEN `hyprlock` SHALL be executed

### Requirement: sleep-action

The panel SHALL display a Sleep button.

#### Scenario: suspend system

WHEN the user clicks the Sleep button
THEN `systemctl suspend` SHALL be executed

### Requirement: screenshot-action

The panel SHALL display a Screenshot button.

#### Scenario: take screenshot

WHEN the user clicks the Screenshot button
THEN `hyprshot -m region` SHALL be executed
AND the popover SHALL close

### Requirement: wifi-network-management

The panel SHALL display the current wifi network name and a button to open nmtui.

#### Scenario: open network manager

WHEN the user clicks the nmtui button
THEN a terminal SHALL open running `nmtui`
