## 1. Python Daemon Core

- [x] 1.1 Create the Python script with evdev device enumeration — find all pointer devices (EV_REL/EV_ABS + BTN_LEFT) and open them
- [x] 1.2 Implement async event loop listening on all pointer devices for BTN_LEFT down/up and REL_X/REL_Y/ABS_X/ABS_Y motion events
- [x] 1.3 Implement long-press detection: 2s timer started on BTN_LEFT down, cancelled on >5px movement or button release
- [x] 1.4 On trigger: capture active window address via `hyprctl activewindow -j` and cursor position via `hyprctl cursorpos -j`
- [x] 1.5 Add permission error handling — log clear message if evdev devices can't be opened (input group missing)

## 2. Rofi Menu Integration

- [x] 2.1 Spawn rofi in dmenu mode with action list (Close, Fullscreen, Float, Minimize, Pin, Move to WS 1-10) positioned at cursor coordinates
- [x] 2.2 Calculate screen-relative cursor position from global coordinates using `hyprctl monitors -j` for multi-monitor support
- [x] 2.3 Map rofi selection to hyprctl dispatch commands targeting the captured window address

## 3. Nix Packaging

- [x] 3.1 Create nix module wrapping the Python script with python3, python-evdev, and rofi as dependencies
- [x] 3.2 Add the module to the home-manager imports in the hyprland default.nix

## 4. Hyprland Integration

- [x] 4.1 Add the daemon to autostart.conf as exec-once
- [x] 4.2 Verify daemon works with both mouse and trackpad input devices
