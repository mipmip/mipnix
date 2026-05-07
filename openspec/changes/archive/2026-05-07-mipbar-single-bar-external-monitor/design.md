## Context

Mipbar uses AGS (GTK4/Astal). Currently `app.ts` calls `app.get_monitors().map(Bar)` at startup, creating a bar per monitor with no lifecycle management. The `Bar` function takes a `Gdk.Monitor` and returns an Astal window anchored to the top of that monitor.

GTK4's `Gdk.Display` emits `monitor-added` and `monitor-removed` signals when monitors are hotplugged. The laptop display is identified as `eDP-1` via Hyprland (`hyprctl monitors`), while external monitors use names like `DP-*`, `HDMI-A-*`.

However, `Gdk.Monitor` objects don't directly expose the Hyprland connector name. They expose `connector`, `model`, `manufacturer`. The `connector` property on `Gdk.Monitor` should match the Wayland/Hyprland output name (e.g., `eDP-1`, `DP-2`).

## Goals / Non-Goals

**Goals:**
- Always show exactly one bar
- Prefer external monitor over laptop display
- React to monitor hotplug (add/remove) in real time
- Clean up the old bar window when switching monitors

**Non-Goals:**
- Multiple bars on multiple monitors
- User-configurable monitor preference
- Supporting more than two monitors (works, but just picks first external)

## Decisions

### 1. Preferred monitor selection logic

**Decision**: `eDP-*` is always the laptop. Any non-eDP monitor is preferred. If multiple externals exist, pick the first one.

```
preferred = monitors.find(m => !isLaptop(m)) ?? monitors[0]
isLaptop(m) = m.connector.startsWith("eDP")
```

### 2. Monitor change handling in app.ts

**Decision**: Connect to `Gdk.Display` signals `monitor-added` and `monitor-removed`. On either event, destroy all existing bar windows and recreate a single bar on the preferred monitor.

**Approach**: Keep a reference to the current bar window. On monitor change, call `window.destroy()` on the old bar, then call `Bar(preferredMonitor)`.

### 3. Unique window names

**Decision**: Each bar window gets a name like `bar-{connector}` to avoid conflicts during transitions.

## Risks / Trade-offs

- **[Gdk.Monitor.connector]** Need to verify that `connector` property is available and matches Hyprland output names in the Wayland session. If not, fall back to checking `model`/`manufacturer`.
- **[Race condition]** Monitor removed + added simultaneously could cause brief flash. → Acceptable for hotplug.
- **[Widget state]** Destroying and recreating the bar loses any transient widget state (open popovers, etc.). → Acceptable.
