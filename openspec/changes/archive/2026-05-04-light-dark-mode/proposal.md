## Why

**Bean**: [mipbar-eiso](../../../.beans/mipbar-eiso--light-and-darkmode.md)

The bar's hover, active, and focused states use hardcoded `rgba(255, 255, 255, ...)` values that only work in dark mode. When the system GTK color scheme switches to light mode (via Hyprland keybinding), these overlays become invisible or look wrong. The bar should automatically follow the system preference.

## What Changes

- Replace all hardcoded white-based rgba hover/active/focused overlays in `style.scss` with theme-aware alternatives using the existing `$fg-color` variable (`@theme_fg_color`)
- Replace the hardcoded `#ff4444` screenshare color with `@error_color` from the GTK theme

## Capabilities

### New Capabilities

None — this is a fix to existing styling, not a new capability.

### Modified Capabilities

None — no spec-level behavior changes, only implementation-level CSS fixes.

## Impact

- `style.scss` — all hardcoded color values replaced with theme-aware equivalents
- No code changes needed — `Bar.tsx` already uses theme variables correctly
