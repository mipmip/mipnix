## Why

The bar currently has a hard, undefined edge where it meets the desktop content below. Adding a thin bottom border with minimal contrast provides subtle visual separation, making the bar feel more polished and intentional without adding visual weight.

## What Changes

- Add a 1px `border-bottom` to the bar's centerbox using `alpha(@theme_fg_color, ~0.08–0.12)` for low contrast
- The border inherits the same transparency approach as the rest of the bar (theme-adaptive via `@theme_fg_color`)

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `bar-visual-style`: Adding a bottom border requirement to the bar's visual style

## Impact

- `packages/mipbar/style.scss` — single CSS property addition to `window.Bar > centerbox`
