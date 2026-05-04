# Quick Settings Panel

**Bean**: [mipbar-0g5a](../../../.beans/mipbar-0g5a--clicking-on-most-right-status-icons-quick-settings.md)
**Status**: proposed

## Why

The bar's status icons (wifi, battery) are display-only. There's no way to adjust volume, toggle bluetooth/wifi/airplane mode, lock the screen, take a screenshot, or suspend without keyboard shortcuts or external tools. A unified quick settings panel (GNOME-style) gives single-click access to all of these.

## What Changes

### NixOS modules (lego2 only)

- Enable `hardware.bluetooth` for bluetooth toggle support
- Ensure WirePlumber is running for volume control (verify with PipeWire config)
- Add `blueman` for external bluetooth pairing UI

### Flake build deps

- Add `wireplumber` and `bluetooth` to `mipbar-astalPackages`
- These propagate to both the Nix package and the devShell

### Mipbar widgets

- Combine Wifi + Battery into a single `<menubutton>` trigger that opens the quick settings panel
- New `QuickSettingsPanel.tsx` popover containing:
  - **Toggle row**: wifi on/off, bluetooth on/off, airplane mode (`rfkill`)
  - **Volume sliders**: speaker + mic via astal wireplumber
  - **Wifi status**: current network name + button to open `nmtui` in terminal
  - **Bluetooth**: on/off toggle + "Pair" button that opens `blueman-manager`
  - **Action buttons**: lock (`hyprlock`), sleep (`systemctl suspend`), screenshot (`hyprshot -m region`)

## Panel Layout

```
┌──────────────────────────────────┐
│  ┌────────┐ ┌────┐ ┌──────────┐ │
│  │ WiFi   │ │ BT │ │ Airplane │ │  toggle buttons
│  └────────┘ └────┘ └──────────┘ │
│                                  │
│  🔊 Speakers  ━━━━━━━━●━━━━━━  │  volume sliders
│  🎤 Mic       ━━━●━━━━━━━━━━━  │
│                                  │
│  WiFi: HomeNetwork    [nmtui ▸] │  current network
│  Bluetooth: on        [Pair ▸]  │  bt status + pair
│                                  │
│  ┌──────┐  ┌──────┐  ┌───────┐ │
│  │ Lock │  │Sleep │  │Screen │ │  action buttons
│  └──────┘  └──────┘  └───────┘ │
└──────────────────────────────────┘
```

## Bar Trigger

The wifi and battery icons merge into one clickable area in the bar. Clicking either opens the panel:

```
Before:  ... [screenshare] [wifi] [battery]
After:   ... [screenshare] [wifi + battery ▾]  ← single menubutton
```

## Capabilities

### New Capabilities

- `quick-settings-panel` — Unified popover for system controls
- `volume-control` — Speaker and mic volume sliders
- `bluetooth-toggle` — On/off toggle with external pairing via blueman
- `airplane-mode` — Toggle all radios via rfkill
- `quick-actions` — Lock, sleep, screenshot buttons

### Modified Capabilities

- `wifi-status` — Moves from standalone icon into the quick settings trigger + panel
- `battery-status` — Moves from standalone icon into the quick settings trigger

## Impact

- `modules/HOSTS/lego2-laptop/configuration.nix` — bluetooth, blueman
- `flake.nix` — add `wireplumber`, `bluetooth` to astalPackages
- New `widget/QuickSettings.tsx` — trigger menubutton with wifi+battery
- New `widget/QuickSettingsPanel.tsx` — popover panel content
- `widget/Bar.tsx` — replace separate Wifi+Battery with QuickSettings
- `widget/Wifi.tsx` — remove (absorbed into QuickSettings)
- `widget/Battery.tsx` — remove (absorbed into QuickSettings)
- `style.scss` — quick settings panel styles

## Assumptions

- Astal `wireplumber` exposes default sink/source with volume bindings
- Astal `bluetooth` exposes adapter powered state
- `blueman-manager` is available for pairing UI
- `hyprshot`, `hyprlock`, `systemctl suspend` are available on PATH
- `rfkill` is available for airplane mode

## Non-goals

- Bluetooth device list or in-panel pairing flow
- WiFi network picker (delegates to nmtui)
- Brightness slider (can be added later)
- Do Not Disturb / notification controls
