# configure-trackpad-input Tasks

## Prerequisites

- [ ] **Decision**: Select implementation option (A, B, C, or D)
- [ ] **Verify**: Test if `sendkeystate` approach works in current Hyprland version

## Option A Tasks (Hyprland-native)

- [ ] Uncomment and test `sendkeystate` binds in `inputs.conf`
- [ ] Verify CTRL+click produces right-click in applications (browser, file manager)
- [ ] Verify normal trackpad click produces left-click
- [ ] Verify external mouse is unaffected
- [ ] Document any limitations discovered

## Option B Tasks (ydotool)

- [ ] Add `ydotool` package to user/system packages
- [ ] Configure `ydotoold` systemd user service
- [ ] Add Hyprland bind for CTRL+click using ydotool
- [ ] Test CTRL+click produces right-click
- [ ] Verify no latency issues
- [ ] Document ydotool dependency in module

## Option C Tasks (libinput quirks)

- [ ] Create NixOS module for libinput quirks
- [ ] Add Framework touchpad quirk to disable BTN_RIGHT/BTN_MIDDLE
- [ ] Rebuild NixOS configuration
- [ ] Verify trackpad only produces left-clicks
- [ ] Add CTRL+click binding (via Option A or B approach)

## Option D Tasks (Hybrid)

- [ ] Complete Option C tasks
- [ ] Complete Option B tasks
- [ ] Integration test full solution

## Validation (All Options)

- [ ] Test in Firefox: CTRL+click opens context menu
- [ ] Test in file manager: CTRL+click shows file context menu
- [ ] Test external USB mouse: All 3 buttons work normally
- [ ] Test after reboot: Configuration persists
- [ ] Document final configuration in module comments
