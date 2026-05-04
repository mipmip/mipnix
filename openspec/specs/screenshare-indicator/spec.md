# Screenshare Indicator

## ADDED Requirements

### Requirement: screenshare-hidden-by-default

The screenshare indicator SHALL NOT be visible when no screenshare session is active.

#### Scenario: no active screenshare

WHEN no screenshare session is active
THEN the screenshare indicator SHALL be hidden

### Requirement: screenshare-visible-when-active

The screenshare indicator SHALL be visible when a screenshare session is active.

#### Scenario: screenshare starts

WHEN a screenshare session becomes active (Hyprland screencast event with state on)
THEN the screenshare indicator SHALL become visible

#### Scenario: screenshare ends

WHEN the screenshare session ends (Hyprland screencast event with state off)
THEN the screenshare indicator SHALL become hidden

### Requirement: screenshare-icon

The screenshare indicator SHALL display a distinct icon that clearly communicates screen sharing is active.

#### Scenario: indicator appearance

WHEN screenshare is active
THEN the indicator SHALL display a recognizable screenshare/camera icon
