# Walker Launcher Button

**Bean**: [mipbar-ysa3](../../../.beans/mipbar-ysa3--walker-launcher-button.md)
**Status**: proposed

## Summary

Add an app launcher button in the top-left corner of the bar that opens the walker menu on click — matching ashell's behavior.

## Motivation

Ashell provides a top-left app launcher button (icon 󱗼) that spawns walker. Since we're replacing ashell with mipbar, we need the same quick access to walker from the bar.

## Design

Replace the current "Welcome to pims AGS!" placeholder button in the start section of the bar with a walker launcher button.

```
┌──────────────────────────────────────────────────────┐
│ [󱗼]                            │           │ [Clock] │
│  └── click → execAsync("walker")                     │
└──────────────────────────────────────────────────────┘
```

### Changes

**`widget/Bar.tsx`**
- Replace the existing start button with an icon button showing 󱗼 (nerd font grid icon)
- Set `halign={Gtk.Align.START}` so it sits flush-left
- `onClicked` calls `execAsync("walker")`

**`style.scss`**
- Optional: add minimal styling for the launcher button (padding, hover state)

## Assumptions

- Walker is already running as a gapplication service via hyprland autostart (`walker --gapplication-service`)
- The nerd font icon 󱗼 is available in the system font stack

## Capabilities

### New Capabilities

- `app-launcher-button` — A button in the bar's start section that launches walker

### Modified Capabilities

None.

## Non-goals

- Starting/managing the walker service from mipbar
- Configuring walker behavior or providers
- Adding other ashell modules (workspaces, tray, etc.) — those are separate changes

## Tasks

1. Update the start button in `widget/Bar.tsx` to show the 󱗼 icon and launch walker on click
2. Align the button to the start (left) of the start section
3. Add hover/active styling for the button in `style.scss`
