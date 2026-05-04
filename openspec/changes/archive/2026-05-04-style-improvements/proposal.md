## Why

The bar currently has visible button chrome (background areas) on most interactive elements — the app launcher, datetime, and systray icons all show a background that contrasts with the bar. The overall bar also feels heavy: too tall, too padded, overly rounded focused workspace indicator. The goal is a cleaner, more minimal look.

Related task: [mipbar-d3tm](.beans/mipbar-d3tm--style-improvements.md)

## What Changes

- Strip default button/menubutton backgrounds so they blend into the bar (only show backgrounds on hover, active, and focused states)
- Add a subtle grouped background around the workspace navigation area
- Reduce overall bar height by tightening padding and min-height values
- Reduce border-radius on the focused workspace indicator (less pill, more subtle)
- Tighten systray icon spacing
- Add slight transparency (alpha 0.9) to the bar background so the wallpaper bleeds through

## Capabilities

### New Capabilities

- `bar-visual-style`: Visual styling rules for the bar — transparency, button chrome, spacing, and height constraints

### Modified Capabilities

None — these are purely visual/CSS changes that don't alter behavior or requirements of existing capabilities.

## Impact

- `style.scss`: All changes are CSS-only — button backgrounds, padding, margins, border-radius, alpha transparency
