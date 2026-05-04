# Bar Visual Style

## ADDED Requirements

### Requirement: transparent-button-backgrounds

All buttons and menubuttons within the bar SHALL have a transparent background in their default (non-interacted) state. Background SHALL only appear on hover, active, and focused states.

#### Scenario: app launcher default state

- **WHEN** the app launcher button is not hovered or active
- **THEN** it SHALL have no visible background (transparent)

#### Scenario: datetime menubutton default state

- **WHEN** the datetime menubutton is not hovered or active
- **THEN** it SHALL have no visible background (transparent)

#### Scenario: systray item default state

- **WHEN** a systray icon is not hovered or active
- **THEN** it SHALL have no visible background (transparent)

#### Scenario: button hover reveals background

- **WHEN** any bar button is hovered
- **THEN** it SHALL display a subtle background to indicate interactivity

### Requirement: bar-transparency

The bar background SHALL be slightly transparent, allowing the wallpaper to bleed through.

#### Scenario: bar background alpha

- **WHEN** the bar is rendered
- **THEN** the centerbox background SHALL use alpha 0.9 of the theme background color

### Requirement: workspace-group-background

The workspace navigation area SHALL have a subtle grouped background to visually contain the workspace buttons.

#### Scenario: workspace container styling

- **WHEN** workspaces are displayed
- **THEN** the Workspaces container SHALL have a subtle background with rounded corners, distinct from individual button backgrounds

### Requirement: compact-bar-height

The bar SHALL use compact spacing to minimize overall height.

#### Scenario: workspace button height

- **WHEN** workspace buttons are rendered
- **THEN** they SHALL use a reduced min-height (no larger than 22px) and tightened padding

#### Scenario: global button margins

- **WHEN** buttons are rendered within the bar
- **THEN** margins SHALL be minimal (no more than 1px)

### Requirement: subtle-focused-indicator

The focused workspace indicator SHALL use a moderate border-radius, not a pill shape.

#### Scenario: focused workspace border-radius

- **WHEN** a workspace button is focused
- **THEN** it SHALL use a border-radius of 8px (matching general button radius, not pill-shaped)

### Requirement: tight-systray-spacing

Systray icons SHALL use compact spacing with minimal padding and margins.

#### Scenario: systray icon spacing

- **WHEN** systray icons are rendered
- **THEN** each icon SHALL have tight padding (no more than 1px vertical, 2px horizontal) and no margin between items

### Requirement: subtle-bottom-border

The bar SHALL have a thin bottom border to visually separate it from desktop content below. The border SHALL use the theme foreground color at low opacity, matching the bar's existing transparency-based styling approach.

#### Scenario: bottom border rendering

- **WHEN** the bar is rendered
- **THEN** the centerbox SHALL have a 1px solid bottom border using `alpha(@theme_fg_color, 0.08)`

#### Scenario: theme adaptation

- **WHEN** the theme switches between light and dark mode
- **THEN** the bottom border SHALL automatically adapt because it derives from `@theme_fg_color`
