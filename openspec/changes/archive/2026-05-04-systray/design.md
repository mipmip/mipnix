# Design: System Tray

## Context

The bar's end section currently has wifi, battery, screenshare, and clock. We need to add a system tray between screenshare and clock. The AGS `tray` package (`AstalTray`) provides reactive bindings for the StatusNotifierItem protocol.

## Goals / Non-Goals

**Goals**:
- Show all registered tray items as clickable icons
- Provide app-supplied context menus on click
- Reactive updates as items register/unregister

**Non-Goals**:
- Custom icon ordering or filtering
- Left-click vs right-click differentiation (menubutton handles this)

## Decisions

### Use AstalTray library

Import `AstalTray` via `gi://AstalTray`. Use `tray.items` binding for the reactive item list.

**Why**: This is the AGS-standard approach. The library handles D-Bus SNI protocol, provides reactive GObject properties, and manages item lifecycle.

### Render items as menubuttons following the simple-bar pattern

Each tray item renders as a `<menubutton>` with:
- `gicon` bound to the item's icon
- `menuModel` set to the item's menu model
- `actionGroup` inserted as "dbusmenu" action group

Use a `$` init callback on the menubutton to wire up the menu model and action group, and subscribe to action group changes.

**Why**: This is the exact pattern from the AGS simple-bar example. The menubutton natively supports GTK menu models, and the dbusmenu action group provides the menu item actions.

### Create a separate Tray widget file

Create `widget/Tray.tsx` as a dedicated component.

**Why**: Consistent with the existing widget-per-feature pattern (Workspaces, Wifi, Battery, Screenshare).

## Risks / Trade-offs

[Risk] Some apps may not register tray items until they detect a tray host → Mitigation: AstalTray registers as a tray host, apps should detect it.

## Open Questions

None.
