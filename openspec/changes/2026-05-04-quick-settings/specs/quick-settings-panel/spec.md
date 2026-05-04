# Quick Settings Panel

## ADDED Requirements

### Requirement: unified-trigger

The bar SHALL display a single clickable area combining the wifi icon and battery icon+percentage that opens the quick settings panel.

#### Scenario: user clicks status area

WHEN the user clicks the wifi+battery area in the bar
THEN the quick settings popover SHALL open

#### Scenario: popover dismissal

WHEN the quick settings popover is open AND the user clicks outside it
THEN the popover SHALL close

### Requirement: panel-layout

The quick settings panel SHALL contain sections in this order: toggle row, volume sliders, wifi status, bluetooth status, action buttons.

#### Scenario: panel renders

WHEN the quick settings popover opens
THEN it SHALL display all sections in the defined order

## MODIFIED Requirements

### Requirement: wifi-display

The wifi icon moves from a standalone bar widget into the quick settings trigger.

#### Scenario: bar layout

WHEN the bar is rendered
THEN the end section order SHALL be: sysmon, clock, tray, screenshare, quick-settings

### Requirement: battery-display

The battery icon and percentage move from a standalone bar widget into the quick settings trigger.

#### Scenario: battery in trigger

WHEN a battery is present
THEN the quick settings trigger SHALL show the battery icon and percentage alongside the wifi icon
