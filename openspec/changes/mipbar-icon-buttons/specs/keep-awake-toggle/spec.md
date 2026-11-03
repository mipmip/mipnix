## ADDED Requirements

### Requirement: on state uses the indicator red

While keep-awake is on, the control SHALL be shown in the same red as the
camera and screen share indicators, in both the dark and the light theme. The
off state SHALL stay grey.

#### Scenario: on in the dark theme

- **WHEN** keep-awake is on and the dark theme is active
- **THEN** the coffee glyph SHALL have the camera indicator's red

#### Scenario: on in the light theme

- **WHEN** keep-awake is on and the light theme is active
- **THEN** the coffee glyph SHALL have the camera indicator's red for the light theme

#### Scenario: glyph optically centred

- **WHEN** the control is shown
- **THEN** the coffee glyph SHALL sit vertically in line with the neighbouring icons
