# Design: Status Icons

## Context

The bar's end section currently contains only a clock menubutton. We need to add wifi, battery, and screenshare status icons to the left of the clock. WiFi and battery use dedicated astal libraries. Screenshare uses Hyprland IPC events via the already-included AstalHyprland library.

## Goals / Non-Goals

**Goals**:
- Show wifi connection state via icon
- Show battery level via icon + percentage text
- Show screenshare indicator only when active
- Clean layout in the end section

**Non-Goals**:
- Interactive controls (network picker, power profiles)
- Audio/volume status (separate change)

## Decisions

### Use AstalNetwork for wifi

Import `AstalNetwork` via `gi://AstalNetwork`. Use `network.wifi` for the wifi device and bind to its `iconName` property for automatic icon updates.

**Why**: Provides reactive GObject properties. The icon name automatically reflects signal strength and connection state via the system icon theme.

### Use AstalBattery for battery

Import `AstalBattery` via `gi://AstalBattery`. Bind to `iconName`, `percentage`, and `isPresent`.

**Why**: Same pattern as wifi. `isPresent` lets us auto-hide on desktops with no battery.

### Use Hyprland event signal for screenshare

Listen to `hyprland.connect("event", ...)` and filter for `screencast` events. The event data format is `state,owner` where state is 1 (on) or 0 (off).

**Why**: No additional dependency needed — AstalHyprland is already included. Avoids polling PipeWire.

**Alternative considered**: Polling `pw-cli list-objects` for screen capture nodes. Rejected because it's heavier and requires a poll interval.

### Create separate widget files per icon

Create `widget/Wifi.tsx`, `widget/Battery.tsx`, `widget/Screenshare.tsx`.

**Why**: Follows the pattern established with `Workspaces.tsx`. Each widget is self-contained with its own library import and reactive bindings.

### Restructure end section as a box

The end section changes from a single menubutton to a `<box>` containing `[Wifi] [Battery] [Screenshare] [Clock]`.

**Why**: Same pattern as the start section restructuring done for workspaces.

## Risks / Trade-offs

[Risk] Hyprland screencast event format may vary across versions → Mitigation: Parse defensively, log unexpected formats.

[Risk] Battery widget shows on desktop with no battery → Mitigation: `isPresent` binding handles this automatically.

## Open Questions

None.
