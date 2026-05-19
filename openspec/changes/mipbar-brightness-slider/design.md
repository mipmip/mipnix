## Context

The mipbar quick settings panel has volume sliders (speaker + mic) using `AstalWp` for reactive bindings. Brightness is currently only controllable via `XF86MonBrightnessUp/Down` keybinds in Hyprland, which shell out to `brightnessctl`. There is no Astal backlight library in the upstream AGS flake — the available packages are: apps, auth, battery, bluetooth, cava, greet, hyprland, io, mpris, network, notifd, powerprofiles, river, tray, wireplumber, wl.

## Goals / Non-Goals

**Goals:**
- Add a brightness slider to the quick settings panel that mirrors the volume slider UX
- Keep brightness in sync when changed via keyboard shortcuts
- Show a brightness icon alongside the slider

**Non-Goals:**
- Multi-monitor brightness control (external monitors) — laptop backlight only
- Adaptive/auto brightness
- Custom brightness curves or profiles

## Decisions

### Use `brightnessctl` via `execAsync` for reading/setting brightness

No `AstalBacklight` GI library exists in the AGS flake. Using `brightnessctl` is consistent with the existing keybind setup and avoids introducing a new dependency. The command interface is straightforward:
- Read: `brightnessctl -m` outputs machine-readable `device,class,current,max,percentage`
- Set: `brightnessctl -e4 -n2 set <value>%` (matches keybind flags for exponential curve and minimum floor)

Alternative considered: Reading/writing `/sys/class/backlight/*/brightness` directly. Rejected because `brightnessctl` already handles device detection, permissions, and the exponential curve (`-e4`).

### Poll brightness on an interval to sync with keyboard changes

Since there's no reactive library, we need to poll `brightnessctl -m` to detect changes made via keyboard shortcuts. A 1-second interval is a reasonable balance — fast enough to feel responsive, cheap enough to be invisible.

Alternative considered: Watching `/sys/class/backlight/*/brightness` via inotify. AGS/GLib does support file monitoring, but backlight sysfs files don't reliably trigger inotify events on all kernels. Polling is simpler and universally reliable.

### Place brightness slider between volume sliders and wifi status

This groups all sliders together visually. The panel order becomes: toggles → volume → brightness → wifi → bluetooth → actions.

### Use `display-brightness-symbolic` as the slider icon

Standard GTK icon name. No dynamic icon changes based on brightness level — keeps it simple and consistent.

## Risks / Trade-offs

- **[Polling overhead]** → 1s poll interval running `brightnessctl -m` is negligible (sub-ms exec time). Can be tuned if needed.
- **[Slider visible on desktops without backlight]** → On desktops, `brightnessctl -m` returns empty/error. The slider component should gracefully hide itself when no backlight device is found.
- **[Exponential curve mismatch]** → The keybinds use `-e4 -n2` flags for exponential scaling. The slider sets a percentage directly. We should use the same flags for consistency so the slider and keys produce the same brightness curve.
