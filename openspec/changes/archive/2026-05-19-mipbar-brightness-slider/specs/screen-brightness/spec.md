# Screen Brightness

## ADDED Requirements

### Requirement: brightness-slider

The quick settings panel SHALL display a slider for adjusting the laptop screen backlight brightness.

#### Scenario: adjust brightness

- **WHEN** the user drags the brightness slider
- **THEN** the screen backlight brightness SHALL change accordingly using `brightnessctl`

#### Scenario: brightness reflects system state

- **WHEN** the panel opens
- **THEN** the brightness slider SHALL reflect the current system backlight brightness

#### Scenario: sync with keyboard shortcuts

- **WHEN** the user changes brightness via keyboard shortcuts while the panel is open
- **THEN** the slider position SHALL update within 1 second to reflect the new brightness

### Requirement: brightness-icon

The brightness slider SHALL display a `display-brightness-symbolic` icon to the left of the slider, matching the volume slider layout.

#### Scenario: icon displayed

- **WHEN** the brightness slider is rendered
- **THEN** a `display-brightness-symbolic` icon SHALL appear to the left of the slider

### Requirement: no-backlight-graceful

The brightness slider SHALL NOT be displayed when no backlight device is available.

#### Scenario: desktop without backlight

- **WHEN** `brightnessctl` reports no backlight device
- **THEN** the brightness slider section SHALL be hidden
