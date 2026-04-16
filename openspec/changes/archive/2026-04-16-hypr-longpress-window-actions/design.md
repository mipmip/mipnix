## Context

Hyprland provides keyboard-driven window management (Super+Q to close, Super+F for fullscreen, etc.) but has no mouse-only mechanism for common window actions. The user switches between keyboard and mouse-only modes (meetings, leaning back). Currently, a 3-finger horizontal swipe switches workspaces, but no gesture or long-press interaction exists for window management.

The existing Hyprland config uses plain `.conf` files symlinked from `modules/user-pim/programs/hyprland/hypr/` via home-manager. Scripts live in `modules/user-pim/programs/hyprland/scripts/`. Packages like `wrofi` are defined inline as `writeShellScriptBin` in nix modules.

## Goals / Non-Goals

**Goals:**
- Long-press LMB (2s hold, <5px movement) opens a context menu at cursor position
- Menu provides: Close, Fullscreen, Float/Tile toggle, Minimize, Pin, Move to Workspace
- Works with any pointing device (mouse, trackpad, pen)
- Actions target the window that was focused when the long-press started
- Daemon runs as a background process, autostarted with Hyprland
- Packaged as a nix derivation with all dependencies

**Non-Goals:**
- Touchpad gesture (3-finger swipe down) for close — could be added later but not in this change
- Customizable actions via config file — hardcoded menu is fine for now
- Theming rofi to match the system theme — functional first, pretty later
- Supporting hold-and-drag or multi-finger long-press variants

## Decisions

### 1. Input detection: python-evdev reading /dev/input/event*

**Rationale**: Hyprland IPC (`hyprctl`) doesn't expose raw button press/release events. Wayland's security model prevents apps from grabbing global input via protocol. Reading evdev devices directly is the standard approach for global input listeners on Linux. `python-evdev` provides a clean async API for this.

**Alternatives considered**:
- `libinput` debug events — requires root, parsing stdout, fragile
- `wev` / `wlhid` — Wayland event viewers, not designed as libraries
- Hyprland plugin — C++ required, overkill for this, harder to iterate on

### 2. All pointer devices, auto-detected

The daemon SHALL enumerate `/dev/input/event*` devices, filter for those with `EV_REL` or `EV_ABS` + `BTN_LEFT` capabilities (pointer devices), and listen on all of them simultaneously using asyncio. New devices (hotplugged) are picked up on restart.

**Rationale**: The user uses both a mouse and a trackpad. Hardcoding a device path would break when switching between them.

### 3. Rofi in dmenu mode for the menu

**Rationale**: Rofi (now wayland-native in nixpkgs, merged from rofi-wayland) supports cursor-relative positioning and dmenu mode. This gives a native context-menu feel — the menu appears right where the cursor is. Wofi and Walker don't support absolute/cursor-relative positioning.

**Alternatives considered**:
- Walker — already in use, but anchored positioning only (centered/edge), not cursor-relative
- Wofi — native Wayland, but same positioning limitation as Walker
- Custom GTK4 popup — full control but significant development effort

### 4. Capture window address before spawning rofi

When the long-press triggers, the daemon captures `hyprctl activewindow -j` to get the window address. Rofi then spawns (taking focus). The selected action is dispatched to the original window by address using `hyprctl dispatch <action> address:<addr>`.

**Rationale**: Rofi takes focus when it appears, changing the active window. Without pre-capture, actions would target rofi itself.

### 5. Nix packaging as writeShellApplication + python script

Follow the existing pattern from `wrofi` — a nix expression that wraps the Python script with its dependencies (python3, python-evdev) and adds rofi to the path. This keeps the daemon self-contained and reproducible.

### 6. Movement detection cancels immediately

On LMB down, a 2-second async timer starts. Any cursor movement exceeding 5px from the initial position cancels the timer immediately (not at the end of 2s). Button release also cancels. This ensures zero interference with normal click, drag, text selection, and scrollbar operations.

## Risks / Trade-offs

**[evdev permission]** → User must be in the `input` group. This is typical for Hyprland users but should be documented. The daemon should log a clear error if it can't open input devices.

**[LMB interference]** → Despite the deadzone and timer, edge cases may exist (e.g., holding mouse still while thinking during text editing). Mitigation: 2s is long enough to be intentional; the menu is dismissable by clicking elsewhere or pressing Escape.

**[Device hotplug]** → New devices plugged in after daemon start won't be detected until restart. Mitigation: acceptable for v1; could add inotify on /dev/input/ later.

**[Multiple monitors]** → Cursor position from `hyprctl cursorpos` is in global layout coordinates. Rofi needs screen-relative coordinates. Mitigation: the daemon must calculate the offset based on the active monitor's position from `hyprctl monitors -j`.

**[Race condition on window capture]** → Between capturing the active window and dispatching the action, the user could switch windows. Mitigation: unlikely in practice (menu appears in <100ms after trigger), and the action targets by address so it goes to the right window regardless.
