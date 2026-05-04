## ADDED Requirements

### Requirement: subtle-bottom-border

The bar SHALL have a thin bottom border to visually separate it from desktop content below. The border SHALL use the theme foreground color at low opacity, matching the bar's existing transparency-based styling approach.

#### Scenario: bottom border rendering

- **WHEN** the bar is rendered
- **THEN** the centerbox SHALL have a 1px solid bottom border using `alpha(@theme_fg_color, 0.08)`

#### Scenario: theme adaptation

- **WHEN** the theme switches between light and dark mode
- **THEN** the bottom border SHALL automatically adapt because it derives from `@theme_fg_color`
