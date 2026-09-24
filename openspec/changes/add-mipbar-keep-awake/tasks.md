## 1. The widget

- [x] 1.1 Add `packages/mipbar/widget/Caffeine.tsx` holding the on/off state and the toggle, and verify `nix build .#packages.x86_64-linux.mipbar` succeeds
- [x] 1.2 Take the inhibit as a transient user unit running `systemd-inhibit --what=idle`, and verify the unit reaches `active` after a start
- [x] 1.3 Read the state back with `systemctl --user is-active`, treating the non-zero exit for an inactive unit as off rather than as an error, and verify the widget reports off for a unit that does not exist
- [x] 1.4 Clear a failed unit with `reset-failed` before every start, and verify the start command is accepted when the name was previously held
- [x] 1.5 Guard against a second click while the first is in flight, and verify the guard is in the code path that runs the start and stop commands
- [x] 1.6 Poll every 5s so a change made outside the bar is picked up, matching the other indicators

## 2. Placement and appearance

- [x] 2.1 Import the widget in `Bar.tsx` and place it after `<SshKey />`, and verify both the import and the element are present
- [x] 2.2 Add the on and off colours to `style.scss` under `.StatusIcon`, and verify the rule sits beside the other status-icon rules
- [x] 2.3 Use a coffee glyph for on and a crossed-out coffee glyph for off, so the state does not depend on colour alone, and verify both glyphs are in the built bundle

## 3. The inhibit behaves

- [x] 3.1 Start the inhibit and verify `systemd-inhibit --list` shows an entry with `mipbar` as the holder, `idle` as what, and `block` as the mode
- [x] 3.2 Verify logind's `BlockInhibited` property reads `idle` while the inhibit is held
- [x] 3.3 Stop the inhibit and verify `BlockInhibited` returns to empty and no `mipbar` entry remains listed
- [ ] 3.4 Turn keep-awake on, leave the session untouched past 10 minutes, and verify the screen does not lock
- [ ] 3.5 Leave it untouched past 15 minutes and verify the display stays powered
- [ ] 3.6 Turn keep-awake off and verify the screen locks at the usual threshold again

## 4. What it must not affect

- [ ] 4.1 With keep-awake on, press `Super+Shift+L` and verify the machine suspends
- [ ] 4.2 With keep-awake on, close the lid and verify the machine suspends
- [ ] 4.3 With keep-awake on, press `Super+L` and verify the session locks
- [ ] 4.4 Verify `hypridle.conf` is unchanged by this change

## 5. Reload and session behaviour

- [x] 5.1 Rebuild and restart the bar, and verify the running bundle contains the widget
- [ ] 5.2 Turn keep-awake on, restart the bar, and verify the inhibit is still held and the control shows on
- [ ] 5.3 Turn it on, stop the unit from a terminal, and verify the control shows off within the poll interval
- [ ] 5.4 Log out and back in, and verify keep-awake is off and no inhibitor belonging to the bar is listed

## 6. Regression

- [x] 6.1 Verify `nix build .#checks.x86_64-linux.mipbar-displays` still passes
- [ ] 6.2 Verify the other status indicators in the bar still render and behave as before
