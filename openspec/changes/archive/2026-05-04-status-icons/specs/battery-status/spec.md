# Battery Status

## ADDED Requirements

### Requirement: battery-icon-and-percentage

The bar SHALL display a battery icon and percentage text reflecting the current charge level.

#### Scenario: battery at 75%

WHEN the battery is at 75% charge
THEN the bar SHALL display a battery icon and "75%" text

#### Scenario: battery charging

WHEN the battery is charging
THEN the bar SHALL display a charging battery icon

### Requirement: battery-visibility

The battery widget SHALL only be visible when a battery is present in the system.

#### Scenario: no battery (desktop)

WHEN the system has no battery
THEN the battery widget SHALL NOT be displayed

#### Scenario: battery present (laptop)

WHEN the system has a battery
THEN the battery widget SHALL be displayed

### Requirement: battery-position

The battery widget SHALL be positioned in the end section, after the wifi icon and before the screenshare indicator.

#### Scenario: layout order

WHEN the bar is rendered with all status icons visible
THEN the order SHALL be: wifi, battery, screenshare, clock
