# System Tray Icons

## ADDED Requirements

### Requirement: show-tray-items

The bar SHALL display an icon for each registered system tray item.

#### Scenario: app registers tray icon

WHEN an application registers a StatusNotifierItem
THEN the bar SHALL display that app's icon in the tray area

#### Scenario: app unregisters tray icon

WHEN an application removes its StatusNotifierItem
THEN the bar SHALL remove that app's icon from the tray area

### Requirement: tray-context-menus

Each tray icon SHALL provide access to the application's context menu when clicked.

#### Scenario: user clicks tray icon

WHEN the user clicks a tray icon
THEN the application's context menu SHALL be displayed

### Requirement: tray-icon-updates

Tray icons SHALL update reactively when the application changes its icon.

#### Scenario: app changes icon

WHEN an application updates its tray icon (e.g., status change)
THEN the displayed icon SHALL update to reflect the new icon

### Requirement: tray-position

The tray SHALL be positioned in the end section, between the screenshare indicator and the clock.

#### Scenario: layout order

WHEN the bar is rendered
THEN the end section order SHALL be: wifi, battery, screenshare, tray, clock
