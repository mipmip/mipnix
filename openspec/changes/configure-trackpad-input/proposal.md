# configure-trackpad-input

## Summary

Configure Framework 13" trackpad under Hyprland/Wayland to behave as a single-button device, with CTRL+click emulating right-click (context menu). The current multi-finger tap and click behaviors should be disabled.

## Status

**PENDING DECISION** - Multiple implementation options available, awaiting user selection.

## Problem Statement

The Framework 13" laptop trackpad currently responds to multi-finger taps and click zones, triggering unintended right/middle click actions. The desired behavior is:

1. **Single-click only**: All physical trackpad clicks should register as primary (left) click
2. **CTRL+click for context menu**: Holding CTRL while clicking should emit a right-click for context menus
3. **Mouse unaffected**: External mouse should retain normal 3-button behavior

## Current Configuration

Located in `modules/users/pim/programs/hyprland/hypr/inputs.conf`:
- `tap-to-click = false` - Already disabled tap gestures
- `clickfinger_behavior = false` - Already disabled multi-finger click differentiation
- Commented-out bind attempts for click remapping (non-functional)

## Options

### Option A: Hyprland-native sendkeystate binds (Preferred if working)

**Approach**: Use Hyprland's `sendkeystate` dispatcher to intercept clicks and remap them.

**Pros**:
- Pure Hyprland configuration, no external tools
- Follows existing config patterns
- Declarative, version-controlled

**Cons**:
- The commented code suggests this was attempted but didn't work
- `sendkeystate` may not intercept at the input event level needed
- Limited documentation on this use case

**Implementation**:
```conf
# Remap CTRL+left-click to right-click
bind = CTRL, mouse:272, sendkeystate, , mouse:273, down, active
bindr = CTRL, mouse:272, sendkeystate, , mouse:273, up, active
```

### Option B: ydotool-based remapping

**Approach**: Use `ydotool` (Wayland-compatible xdotool alternative) via Hyprland binds to emit synthetic right-clicks.

**Pros**:
- Works at Wayland protocol level
- Proven approach for input remapping
- Can be extended for other gestures

**Cons**:
- Requires `ydotool` package and daemon
- Additional system service (ydotoold)
- Slight latency possible

**Implementation**:
- Add `ydotool` to system packages
- Start `ydotoold` as user service
- Bind: `bind = CTRL, mouse:272, exec, ydotool click 0xC0`

### Option C: libinput quirks file (System-level)

**Approach**: Create libinput quirks to disable physical right/middle buttons at the device level.

**Pros**:
- Works at lowest level (before compositor)
- No Hyprland config changes needed for disable part
- Consistent across all applications

**Cons**:
- System-level change (requires sudo/NixOS config)
- Still need Hyprland binds for CTRL+click
- Less flexible if needs change

**Implementation**:
```nix
# In NixOS configuration
environment.etc."libinput/local-overrides.quirks".text = ''
  [Framework Touchpad Single Button]
  MatchName=*Touchpad*
  MatchDMIModalias=*Framework*
  AttrEventCode=-BTN_RIGHT;-BTN_MIDDLE
'';
```

### Option D: Hybrid libinput + ydotool

**Approach**: Combine Option C (disable buttons at libinput level) with Option B (ydotool for CTRL+click).

**Pros**:
- Most robust solution
- Clean separation of concerns
- Works reliably across all scenarios

**Cons**:
- Most complex setup
- Two systems to configure and maintain

## Recommendation

Start with **Option A** to verify if Hyprland's native approach works (quick test). If it doesn't intercept correctly, proceed to **Option B** (ydotool) as it's well-documented for Wayland input manipulation.

Option C/D are available if lower-level control is needed.

## Questions for User

1. Did you test the commented-out `sendkeystate` binds? What was the behavior?
2. Is adding `ydotool` as a dependency acceptable?
3. Should the solution be purely Hyprland-config or is NixOS-level (libinput quirks) acceptable?

## Scope

- **In scope**: Trackpad click behavior, CTRL+click binding
- **Out of scope**: Gestures (swipe, pinch), external mouse configuration, other keyboard modifiers

## Related Specs

- `home-manager-config`: Module structure for Hyprland config
