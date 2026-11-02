# Proposal

## Why

On delliebellie the lock screen asks for the password and then the fingerprint. Either one should be enough. `nixos-hardware` (dell/xps/13-9315) turns on fprintd, and NixOS then puts `pam_fprintd` in front of `pam_unix` in every PAM service. hyprlock starts PAM only after Enter, so the password is typed first and the PAM stack then waits for the finger.

## What Changes

- hyprlock checks the fingerprint itself through fprintd over D-Bus (`auth { fingerprint { enabled = true } }`), alongside the password. The first one to succeed unlocks.
- The `hyprlock` PAM service drops `pam_fprintd` and asks for the password only.
- The `sudo` and `polkit-1` PAM services drop `pam_fprintd` and ask for the password only.
- GDM is unchanged: it already has its own fingerprint path.
- The input field placeholder says that a finger works too.

## Capabilities

### New Capabilities

- `fingerprint-auth`: which authentication paths accept a fingerprint and which ask for the password only.

### Modified Capabilities

- `screen-lock`: the lock screen unlocks with the password or with an enrolled fingerprint, either one alone.

## Impact

- `modules/programs/desktop/de/hyprland.nix`: `fprintAuth = false` for `hyprlock`, `sudo` and `polkit-1`.
- `modules/USERS/pim/programs/hyprland/hypr/hyprlock.conf`: an `auth` block and a new placeholder.
- Every Hyprland host. On hosts without fprintd the PAM settings change nothing, and hyprlock finds no fingerprint device and keeps working with the password.
- Rollout: `rme up_machine` and `rme up_home` per host.
