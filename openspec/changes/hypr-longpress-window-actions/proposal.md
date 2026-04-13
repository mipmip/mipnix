## Why

When in "mouse mode" (leaning back, in a meeting, not near the keyboard), there's no way to close or manage windows without reaching for a key combo like Super+Q. A long-press gesture on any pointing device (mouse or trackpad) that opens a window action menu would make window management fully mouse-accessible.

## What Changes

- Add a Python daemon (`hypr-longpress`) that listens to evdev pointer events and detects a 2-second left-click hold with minimal cursor movement (<5px)
- On trigger, capture the active window address and cursor position, then spawn a rofi dmenu at the cursor location with window actions (Close, Fullscreen, Float, Minimize, Pin, Move to Workspace)
- The selected action is dispatched to the captured window via `hyprctl dispatch`
- Package the daemon as a Nix derivation with python3, python-evdev, and rofi as dependencies
- Autostart the daemon in the Hyprland autostart config

## Capabilities

### New Capabilities
- `hypr-longpress-window-actions`: Long-press LMB (2s, <5px movement) on any window opens a rofi context menu at the cursor with window management actions. Works with any pointing device (mouse, trackpad). Actions dispatched via hyprctl to the window that was focused before rofi appeared.

### Modified Capabilities

## Impact

- `modules/user-pim/programs/hyprland/` — new nix module for the daemon package and home-manager integration
- `modules/user-pim/programs/hyprland/hypr/autostart.conf` — add daemon to autostart
- `modules/programs/desktop/de/hyprland.nix` — add rofi to system packages (already available in nixpkgs as `rofi`, which is now wayland-native)

## Design Considerations

- **evdev permissions**: User must be in the `input` group to read `/dev/input/event*` devices
- **Multiple devices**: Daemon listens on all pointer-type evdev devices (mice, trackpads)
- **Focus capture**: Active window address is captured *before* spawning rofi, since rofi takes focus when it appears. Actions are dispatched to the original window by address.
- **Deadzone**: 5px movement threshold prevents accidental triggers during normal click-drag operations (text selection, window dragging, scrollbar use)
- **No keyboard conflict**: This system is entirely additive — existing Super+Q and other keybinds remain unchanged
