# App Launcher Button

## ADDED Requirements

### Requirement: launcher-button-presence

The bar SHALL display an app launcher button in the start (left) section of the centerbox.

#### Scenario: button is visible on bar load

WHEN the bar is loaded on a monitor
THEN an app launcher button SHALL be visible in the top-left area of the bar

### Requirement: launcher-button-icon

The app launcher button SHALL display the 󱗼 nerd font icon as its label.

#### Scenario: button shows correct icon

WHEN the bar is rendered
THEN the launcher button SHALL display the 󱗼 icon

### Requirement: launcher-button-alignment

The app launcher button SHALL be aligned to the start (left) of the start section.

#### Scenario: button is flush-left

WHEN the bar is rendered
THEN the launcher button SHALL have `halign` set to `START`
AND the button SHALL NOT expand to fill available space

### Requirement: launcher-opens-walker

Clicking the app launcher button SHALL execute `walker` via `execAsync`.

#### Scenario: clicking the button opens walker

WHEN the user clicks the app launcher button
THEN the system SHALL call `execAsync("walker")`
AND the walker application launcher SHALL appear

### Requirement: launcher-button-styling

The app launcher button SHALL have hover and active visual feedback.

#### Scenario: hover state

WHEN the user hovers over the launcher button
THEN the button SHALL display a visible hover state

#### Scenario: active state

WHEN the user clicks and holds the launcher button
THEN the button SHALL display a visible active/pressed state
