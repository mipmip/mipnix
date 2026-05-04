### Requirement: Interactive states follow system color scheme
The bar's interactive states (hover, active, focused) SHALL use theme-aware colors that adapt to both light and dark GTK color schemes.

#### Scenario: Dark mode hover states
- **WHEN** the system GTK color scheme is set to dark
- **THEN** hover/active/focused overlays appear as light semi-transparent overlays on the dark background

#### Scenario: Light mode hover states
- **WHEN** the system GTK color scheme is set to light
- **THEN** hover/active/focused overlays appear as dark semi-transparent overlays on the light background

### Requirement: Status indicators follow system color scheme
Status indicator colors (e.g., screenshare warning) SHALL use GTK theme semantic colors rather than hardcoded values.

#### Scenario: Screenshare indicator in both modes
- **WHEN** screenshare is active
- **THEN** the indicator uses the GTK theme's error color, visible in both light and dark modes
