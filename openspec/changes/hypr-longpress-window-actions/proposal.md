## Why

When in "mouse mode" (leaning back, in a meeting, not near the keyboard), there's no way to close or manage windows without reaching for a key combo like Super+Q. A long-press gesture on any pointing device (mouse or trackpad) that opens a window action menu would make window management fully mouse-accessible.

## What Changes

- Add a Python daemon (`hypr-longpress`) that parses `libinput debug-events` output to detect a 2-second left-click hold with minimal cursor movement (<5px)
- On trigger, capture the active window address and cursor position, then spawn a rofi dmenu at the cursor location with window actions (Close, Fullscreen, Float, Minimize, Pin, Move to Workspace 1-10)
- Rofi is styled as a mouse-friendly context menu: hover-select, single-click confirm, fat rows with padding, hidden input bar, rounded corners
- The selected action is dispatched to the captured window via `hyprctl dispatch`
- Package the daemon as a Nix derivation with python3, libinput, and rofi as dependencies
- Autostart the daemon in the Hyprland autostart config
- Add user to `input` group in NixOS config for libinput access

## Capabilities

### New Capabilities
- `hypr-longpress-window-actions`: Long-press LMB (2s, <5px movement) on any window opens a rofi context menu at the cursor with window management actions. Works with any pointing device (mouse, trackpad). Hover-select and single-click confirm for mouse-native interaction. Actions dispatched via hyprctl to the window that was focused before rofi appeared.

### Modified Capabilities

## Impact

- `modules/user-pim/programs/hypr-longpress.nix` — new home-manager module wrapping the daemon with python3, libinput, and rofi
- `modules/user-pim/programs/hyprland/scripts/hypr-longpress` — Python daemon script
- `modules/user-pim/programs/hyprland/hypr/autostart.conf` — add daemon to autostart
- `modules/user-pim/hm-pim.nix` — add `pim-hypr-longpress` to home-manager imports
- `modules/user-pim/nixos-pim.nix` — add `input` group to user's extraGroups

## Design Considerations

- **libinput over evdev**: Hyprland grabs input devices exclusively, so raw evdev reads receive no events. The daemon parses `libinput debug-events` output instead, which can read alongside the compositor.
- **input group**: User must be in the `input` group for libinput to access `/dev/input/event*` devices. Added declaratively in NixOS user config.
- **Focus capture**: Active window address is captured *before* spawning rofi, since rofi takes focus when it appears. Actions are dispatched to the original window by address.
- **Timer task lifecycle**: The async timer task reference is cleared before calling `on_trigger`, preventing button-release events from cancelling the menu interaction mid-flight.
- **Deadzone**: 5px cumulative movement threshold prevents accidental triggers during normal click-drag operations (text selection, window dragging, scrollbar use).
- **Mouse-friendly rofi**: Hover-select with single-click confirm, hidden input bar, 10px padded rows, rounded corners — feels like a native context menu rather than a keyboard launcher.
- **No keyboard conflict**: This system is entirely additive — existing Super+Q and other keybinds remain unchanged.
