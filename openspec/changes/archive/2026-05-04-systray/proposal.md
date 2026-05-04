# System Tray

**Bean**: [mipbar-mkga](../../../.beans/mipbar-mkga--systray-most-right-2.md)
**Status**: proposed

## Why

Background apps (Discord, Tailscale, Nextcloud, etc.) expose status icons and context menus via the StatusNotifierItem (SNI) tray protocol. The bar needs a system tray to show these icons and provide access to their menus.

## What Changes

- Add `tray` astal package to `flake.nix`
- Create a Tray widget showing all tray items as menubuttons with their app-provided context menus
- Place it in the end section between the status icons and the clock

## Capabilities

### New Capabilities

- `systray-icons` — Show system tray icons with their context menus

### Modified Capabilities

None.

## Impact

- `flake.nix` — add `tray` to astalPackages
- New `widget/Tray.tsx`
- `widget/Bar.tsx` — add Tray between Screenshare and clock
- `style.scss` — tray icon styles

## Assumptions

- `AstalTray` provides reactive tray item list via SNI protocol
- Each tray item exposes `gicon`, `menuModel`, and `actionGroup`
- Apps are already registering with the tray protocol (they do when a bar is running)

## Non-goals

- Custom tray icon ordering or filtering
- Tray icon pinning/hiding
- Custom right-click menus (apps provide their own)
