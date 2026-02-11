# configure-trackpad-input Design

## Architecture Overview

This change affects the input processing pipeline at potentially three levels:

```
Hardware (Touchpad)
       |
       v
+------------------+
| libinput (kernel)|  <-- Option C: Quirks file disables buttons here
+------------------+
       |
       v
+------------------+
| Hyprland         |  <-- Option A: sendkeystate intercepts here
| (Compositor)     |
+------------------+
       |
       v
+------------------+
| Application      |
+------------------+
       ^
       |
+------------------+
| ydotool          |  <-- Option B: Injects synthetic events
+------------------+
```

## Input Event Codes Reference

| Event | Code | Description |
|-------|------|-------------|
| BTN_LEFT | mouse:272 | Primary click |
| BTN_RIGHT | mouse:273 | Secondary click (context menu) |
| BTN_MIDDLE | mouse:274 | Middle click |

## Hyprland Bind Syntax

```
bind = MODS, key, dispatcher, args...
bindr = MODS, key, dispatcher, args...  # on release
```

For `sendkeystate`:
```
sendkeystate, [window], key, state, [mode]
```
- `state`: `down`, `up`, or `toggle`
- `mode`: `active` (focused window) or empty

## libinput Quirks Syntax

```ini
[Section Name]
MatchName=glob-pattern
MatchDMIModalias=dmi:*svnFramework*
AttrEventCode=-BTN_RIGHT;-BTN_MIDDLE  # Disable these buttons
```

## ydotool Commands

```bash
ydotool click 0xC0    # Right click (button 2, 0x40 << 1 = 0xC0)
ydotool click 0x40    # Left click
ydotool click 0x100   # Middle click
```

Note: ydotool requires `ydotoold` daemon running with appropriate permissions.

## NixOS Integration Points

### Hyprland Config (Options A, B)
```
modules/users/pim/programs/hyprland/hypr/inputs.conf
```

### ydotool Package (Option B)
```nix
# In home packages or system packages
home.packages = [ pkgs.ydotool ];
```

### ydotoold Service (Option B)
```nix
systemd.user.services.ydotoold = {
  Unit.Description = "ydotool daemon";
  Service.ExecStart = "${pkgs.ydotool}/bin/ydotoold";
  Install.WantedBy = [ "default.target" ];
};
```

### libinput Quirks (Option C)
```nix
# In NixOS system configuration
environment.etc."libinput/local-overrides.quirks".text = ''
  [Framework Touchpad]
  MatchName=*Touchpad*
  AttrEventCode=-BTN_RIGHT;-BTN_MIDDLE
'';
```

## Trade-off Analysis

| Criterion | Option A | Option B | Option C | Option D |
|-----------|----------|----------|----------|----------|
| Complexity | Low | Medium | Medium | High |
| Reliability | Unknown | High | High | Highest |
| Dependencies | None | ydotool | None | ydotool |
| Config Level | User | User+Service | System | Both |
| Reversibility | Easy | Easy | Easy | Medium |

## Testing Strategy

1. **Unit test**: Each bind/config in isolation
2. **Integration test**: Full workflow (CTRL+click in app)
3. **Regression test**: External mouse still works
4. **Persistence test**: Works after reboot/logout
