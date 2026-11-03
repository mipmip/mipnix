## ADDED Requirements

### Requirement: uniform-icon-buttons

Every icon in the bar's end section, other than the tray, the clock and the
quick settings group, SHALL be presented as a button with the same padding,
corner radius and hover background as the system monitor button. The padding
SHALL lie inside the hover area. An icon SHALL get this presentation from one
shared style, so an icon added later is presented the same way without styling
of its own.

#### Scenario: hovering any icon

- **WHEN** the pointer is over the notifications, displays, SSH key,
  minimized, all windows, keep-awake, camera, screen share or system monitor
  icon
- **THEN** a rounded hover background SHALL appear with the same size around
  the glyph for each of them

#### Scenario: plain-button icons

- **WHEN** the keep-awake, camera or screen share icon is shown
- **THEN** it SHALL have the same padding and hover as the menu button icons

#### Scenario: a new icon

- **WHEN** a new icon widget is added to the bar using the shared class and no
  padding or hover rules of its own
- **THEN** it SHALL be presented like the other icons

#### Scenario: guarded by a test

- **WHEN** the mipbar tests run
- **THEN** they SHALL fail if an icon widget in the bar's end section lacks
  the shared class, or if the stylesheet strips the button styling of icons

#### Scenario: equal indicator size

- **WHEN** the camera and screen share icons are shown
- **THEN** their icons SHALL have the same size
