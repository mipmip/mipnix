# Design: Quick Settings Panel

## Context

The bar's right side has individual status icons (wifi, battery, screenshare, tray, sysmon, clock). Wifi and battery are display-only. We want a unified quick settings panel — a single popover triggered by clicking the wifi+battery area — that provides toggles, volume sliders, and quick actions.

The bar already uses the `<menubutton>` + `<popover>` pattern for the clock (calendar) and system monitor. We extend this pattern for quick settings.

## Goals / Non-Goals

**Goals**:
- Single unified panel for common system controls
- Volume control for speakers and mic
- Wifi/bluetooth/airplane toggles
- Quick actions: lock, sleep, screenshot
- Delegate complex flows to external tools (nmtui, blueman)

**Non-Goals**:
- In-panel wifi network picker
- In-panel bluetooth device list or pairing flow
- Brightness slider (future addition)
- Notification / DND controls

## Decisions

### Combine wifi + battery into a single menubutton trigger

The wifi icon and battery icon+percentage merge into one `<menubutton>` that opens the quick settings popover. They remain visually distinct inside the button but act as one click target.

**Why**: GNOME-style — the status area is one interaction target. Avoids per-icon popovers which fragment the UX.

### New QuickSettings.tsx for the trigger, QuickSettingsPanel.tsx for the popover content

`QuickSettings.tsx` contains the `<menubutton>` with wifi+battery display (the bar-visible part). `QuickSettingsPanel.tsx` contains the popover content (toggles, sliders, actions). Wifi.tsx and Battery.tsx are removed — their logic moves into QuickSettings.

**Why**: Keeps the trigger slim and the panel content in its own file. The panel will be substantial, so separating it avoids a bloated single file.

### Use astal wireplumber for volume control

Import `AstalWp` for speaker/mic volume. Bind GTK4 `<Scale>` sliders to the default audio sink and source volume properties.

**Why**: Astal wireplumber provides reactive GObject bindings to PipeWire via WirePlumber. This is the AGS-standard approach for audio control.

### Use astal bluetooth for the toggle only

Import `AstalBluetooth` to get the default adapter. Bind a toggle button to `adapter.powered`. The "Pair" button opens `blueman-manager` via `execAsync`.

**Why**: Full bluetooth device management in a popover is complex (scanning, PIN confirmation, etc.). Delegating to blueman keeps scope small while still providing the most common action (on/off) inline.

### Airplane mode via rfkill

Toggle all radios with `rfkill block all` / `rfkill unblock all` via `execAsync`. Read state with `rfkill list` to determine current status.

**Why**: rfkill is the standard Linux interface for radio control. No astal library needed.

### Actions are direct exec calls

- Lock: `hyprlock`
- Sleep: `systemctl suspend`
- Screenshot: `hyprshot -m region`

**Why**: These are already configured/available on the system. No library bindings needed.

### Open nmtui in the default terminal

The wifi row shows the current network name and a button that runs `execAsync("ghostty -e nmtui")` (or whatever `$TERMINAL` is set to).

**Why**: nmtui is a full network manager TUI. Opening it in a terminal is simpler and more capable than building a wifi picker widget.

### NixOS bluetooth module on lego2

Add `hardware.bluetooth.enable = true` and `services.blueman.enable = true` to lego2's configuration. This provides the bluetooth stack and the external pairing tool.

**Why**: Bluetooth hardware support and blueman aren't currently configured. Required for the bluetooth toggle and pair button to function.

## Component Diagram

```
Bar (right side)
├── SystemMonitor (existing)
├── Clock/Calendar (existing)
├── Tray (existing)
├── Screenshare (existing)
└── QuickSettings ← NEW (menubutton trigger)
    ├── [wifi icon] [battery icon + %]  ← visible in bar
    └── <popover>
        └── QuickSettingsPanel ← NEW
            ├── ToggleRow: wifi, bluetooth, airplane
            ├── VolumeSliders: speaker, mic
            ├── WifiStatus: current network + nmtui button
            ├── BluetoothStatus: on/off + pair button
            └── ActionButtons: lock, sleep, screenshot
```

## Data Flow

```
AstalNetwork ──────► wifi icon + toggle + network name
AstalBattery ──────► battery icon + percentage
AstalWp ───────────► speaker/mic volume sliders
AstalBluetooth ────► bluetooth toggle state
rfkill (exec) ─────► airplane mode state
execAsync ─────────► lock, sleep, screenshot, nmtui, blueman
```

## Risks / Trade-offs

[Risk] rfkill airplane mode may interfere with bluetooth toggle state → Mitigation: after toggling airplane mode, re-read bluetooth adapter state to update the toggle.

[Risk] WirePlumber may not be explicitly enabled on lego2 → Mitigation: verify `services.pipewire.wireplumber.enable` in hardware.nix, add if missing.

[Risk] Popover may be too tall on small screens → Mitigation: keep layout compact, can add scrolling later if needed.

## Open Questions

None.
