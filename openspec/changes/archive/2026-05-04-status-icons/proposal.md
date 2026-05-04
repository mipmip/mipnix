# Status Icons

**Bean**: [mipbar-rpm4](../../../.beans/mipbar-rpm4--most-right-common-status-icons.md)
**Status**: proposed

## Why

The bar needs common system status indicators so the user can see wifi connectivity, battery level, and screenshare state at a glance — replacing ashell's equivalent widgets.

## What Changes

- Add `network` and `battery` astal packages to `flake.nix`
- Create WiFi status icon widget (icon reflecting connection state)
- Create Battery status icon widget (icon + percentage)
- Create Screenshare indicator (hidden by default, visible only during active screenshare)
- Place all status icons in the end section, left of the clock
- Add styles for the status icons

## Capabilities

### New Capabilities

- `wifi-status` — Icon showing wifi connection state
- `battery-status` — Icon with percentage showing battery level
- `screenshare-indicator` — Icon visible only during active screenshare

### Modified Capabilities

None.

## Impact

- `flake.nix` — add `network`, `battery` to astalPackages
- New widget files for each status icon
- `widget/Bar.tsx` — restructure end section to hold status icons + clock
- `style.scss` — status icon styles

## Assumptions

- `AstalNetwork` provides wifi icon and connection state reactively
- `AstalBattery` provides battery icon, percentage, and isPresent
- Hyprland `screencast` event available via `AstalHyprland` event signal
- Battery widget auto-hides when no battery is present (desktop monitor)

## Non-goals

- WiFi network picker/dropdown
- Battery power profile switching
- Screenshare start/stop controls
- Bluetooth status
