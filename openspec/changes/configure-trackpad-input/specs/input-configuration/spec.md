# input-configuration Specification

## Purpose

Define requirements for Hyprland input device configuration, specifically trackpad behavior and click remapping for the Framework 13" laptop.

## ADDED Requirements

### Requirement: Single-Button Trackpad Mode

The system SHALL configure the Framework laptop trackpad to operate as a single-button device, disabling multi-finger click differentiation.

#### Scenario: Physical trackpad click produces left-click only
- **GIVEN** the Hyprland compositor is running
- **AND** the user is using the built-in Framework trackpad
- **WHEN** the user physically clicks anywhere on the trackpad
- **THEN** the system SHALL emit a left-click (BTN_LEFT/mouse:272) event
- **AND** multi-finger clicks SHALL NOT produce different button events

#### Scenario: Tap gestures remain disabled
- **GIVEN** `tap-to-click = false` is configured
- **WHEN** the user taps (without physical click) on the trackpad
- **THEN** no click event SHALL be emitted

### Requirement: CTRL+Click Right-Click Emulation

The system SHALL emulate right-click (context menu) when the user holds CTRL and clicks the trackpad.

#### Scenario: CTRL+click produces context menu
- **GIVEN** the Hyprland compositor is running
- **WHEN** the user holds the CTRL key
- **AND** the user clicks the trackpad
- **THEN** the system SHALL emit a right-click (BTN_RIGHT/mouse:273) event
- **AND** applications SHALL display their context menu

#### Scenario: CTRL+click works across applications
- **GIVEN** a web browser (Firefox) is focused
- **WHEN** the user performs CTRL+click on a link
- **THEN** the browser context menu SHALL appear
- **AND** the link SHALL NOT open in a new tab (which is CTRL+left-click behavior)

### Requirement: External Mouse Independence

The system SHALL NOT affect external mouse button behavior when configuring trackpad click remapping.

#### Scenario: External USB mouse retains 3-button functionality
- **GIVEN** an external USB mouse is connected
- **AND** trackpad single-button mode is configured
- **WHEN** the user clicks the right mouse button on the external mouse
- **THEN** a right-click event SHALL be emitted normally
- **AND** no remapping SHALL be applied to the external mouse

## Related Capabilities

- `home-manager-config`: Module structure for user configuration
