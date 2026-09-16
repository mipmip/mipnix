> Work the sections in order. Section 1 must be rebuilt and verified before
> section 3 arms any automatic trigger, otherwise the first automatic lock is
> also the first test of an authentication path that currently always fails.

## 1. Make hyprlock authenticatable

- [ ] 1.1 In `modules/programs/desktop/de/hyprland.nix`, set
      `programs.hyprlock.enable = true;`. Add a comment recording why: NixOS
      ships default PAM stacks for `swaylock`/`i3lock`/`vlock`/`xlock` but not
      for hyprlock, so without this the locker falls through to
      `/etc/pam.d/other`, which is `pam_warn` + `pam_deny`.
- [ ] 1.2 Remove `hyprlock` from `environment.systemPackages` in the same file.
      `programs.hyprlock.enable` installs the package already.
- [ ] 1.3 Rebuild `cichorei`. Confirm `/etc/pam.d/hyprlock` now exists and
      contains a `pam_unix` auth line.

## 2. Verify authentication by hand, with an escape hatch

- [ ] 2.1 Open an SSH session to `cichorei` from another machine and leave it
      open. `pkill hyprlock` from there is the way out if the lock screen will
      not accept the password.
- [ ] 2.2 Press `SUPER+L`. Confirm the account password unlocks the session.
- [ ] 2.3 While the lock screen is up, observe whether the clock, the date and
      the `Password...` placeholder render as text or as boxes. Record the
      result; it decides section 6.
- [ ] 2.4 Confirm an incorrect password does not unlock.

## 3. Idle and sleep policy

- [ ] 3.1 Add `hypridle` to `environment.systemPackages` in
      `modules/programs/desktop/de/hyprland.nix` and remove `swayidle`, which
      nothing references once the dead `autostart.conf` line is gone.
- [ ] 3.2 Create `modules/USERS/pim/programs/hyprland/hypr/hypridle.conf` with
      the policy from `design.md`: `lock_cmd = pidof hyprlock || hyprlock`,
      `before_sleep_cmd = loginctl lock-session`,
      `after_sleep_cmd = hyprctl dispatch dpms on`, a 600 second listener that
      locks, and a 900 second listener that turns DPMS off with an `on-resume`
      that turns it back on. Do not put an `on-resume` on the lock listener.
- [ ] 3.3 In `modules/USERS/pim/programs/hyprland/hypr/autostart.conf`, replace
      the commented `swayidle` line at line 7 with `exec-once = hypridle`, and
      update the surrounding comment to state the actual policy (lock at 10 min,
      display off at 15, never suspend on idle).
- [ ] 3.4 Note in a comment near the `exec-once` why the NixOS
      `services.hypridle` module is not used: its unit is
      `WantedBy = graphical-session.target`, which this session does not
      populate, the same reason Walker and hyprpolkitagent are exec-once'd.

## 4. Declare the no-idle-suspend intent

- [ ] 4.1 In `modules/programs/desktop/de/hyprland.nix`, add
      `services.logind.settings.Login.IdleAction = "ignore";` with a comment
      explaining that this changes nothing today (it matches the systemd
      default) and exists so the machine's refusal to sleep on idle is a stated
      property of the repo rather than an inherited default.
- [ ] 4.2 Confirm the option name resolves against the pinned nixpkgs. The
      deprecated `services.logind.extraConfig` form must not be used.

## 5. Fix the keybinds

- [ ] 5.1 In `modules/USERS/pim/programs/hyprland/hypr/binds.conf`, change
      `bind = $mainMod, L, exec, hyprlock` to
      `bind = $mainMod, L, exec, pidof hyprlock || hyprlock`.
- [ ] 5.2 Change `bind = $mainMod SHIFT, L, exec, hyprlock && systemctl suspend`
      to `bind = $mainMod SHIFT, L, exec, systemctl suspend`, with a comment that
      hypridle's `before_sleep_cmd` does the locking. The old form suspended only
      after the user had already unlocked.
- [ ] 5.3 Leave the binds resolving to `hyprlock` directly rather than
      `loginctl lock-session`, so the manual lock works even if hypridle is not
      running. See the keybind decision in `design.md`.

## 6. Lock screen legibility

- [ ] 6.1 If section 2.3 recorded readable text, close this section as resolved
      and record in the bean that the box-glyph symptom no longer reproduces.
- [ ] 6.2 If boxes still appear, investigate before changing anything: check
      whether hyprlock sees fontconfig at all (compare `fc-match "Noto Sans"` in
      the session against what hyprlock resolves), and whether the pango markup
      in the `placeholder_text` is involved. Only then adjust
      `hypr/hyprlock.conf`.

## 7. Verify the whole policy

- [ ] 7.1 Rebuild and reload. Confirm `pgrep hypridle` reports a running daemon.
- [ ] 7.2 Idle for 10 minutes without touching the machine. Confirm the screen
      locks and the machine is still reachable over SSH.
- [ ] 7.3 Keep idling to 15 minutes. Confirm the display powers down, the
      machine is still reachable over SSH, and input brings back the lock screen
      rather than the desktop.
- [ ] 7.4 Confirm activity before 10 minutes resets the timer and nothing locks.
- [ ] 7.5 Close the lid, wait for suspend, reopen. Confirm the lock screen is
      present and the display is on.
- [ ] 7.6 Run `loginctl lock-session` from a terminal. Confirm it locks, which
      proves the DBus lock verb works for any future caller.
- [ ] 7.7 Press `SUPER+SHIFT+L`. Confirm the machine locks and then suspends,
      in that order.
- [ ] 7.8 Leave the session idle overnight. Confirm in the morning that the
      machine is locked and was never suspended (`journalctl -b -u systemd-suspend`
      or `last -x | head` shows no suspend entries).

## 8. Roll out to the second host

- [ ] 8.1 Rebuild `doornappel` only after section 7 passes on `cichorei`.
- [ ] 8.2 Repeat 7.1, 7.2 and 7.5 on `doornappel`.

## 9. Close the loop

- [ ] 9.1 Update `.beans/mipnix-nhpf--fix-lock-screen-and-enable-timer-again.md`
      frontmatter: `status: completed`, refresh `updated_at`, and add the
      `openspec-link` to the archived change.
