<!--
Backfilled retroactively: this change was implemented and verified working
before the OpenSpec artifacts were written, to preserve the (non-obvious)
rationale. The implementation is already in the repo.
-->

## Why

The Hyprland session had **no polkit authentication agent** running. GNOME/KDE
sessions ship one automatically; a bare Hyprland session (launched by GDM, no
uwsm/systemd integration) does not. Without a running agent, any polkit-mediated
authentication prompt has nowhere to appear.

The concrete symptom that surfaced this: the Bitwarden desktop app's **"Unlock
with system authentication"** (its Linux biometric/fingerprint unlock) works
through polkit, and its lock-screen biometric prompt could never appear — so
biometric unlock was effectively unusable even though the fingerprint hardware
(`services.fprintd` + enrolled prints) and the `pam_fprintd` entry in
`/etc/pam.d/polkit-1` were already in place. More broadly, any GUI app needing
elevated authentication in the session was affected.

## What Changes

- Add `hyprpolkitagent` (the Hyprland-native polkit authentication agent) to the
  pim Hyprland home-manager module.
- Launch it at session start via `exec-once` in `autostart.conf`, using a small
  PATH wrapper (`hyprpolkitagent-start`) that execs the package's `libexec`
  binary directly.

Two implementation subtleties, both learned the hard way and encoded in the fix:

- **Do NOT start it via its systemd user unit.** The Qt6 agent crashes
  (`SIGABRT` / core-dump) under the unit's restricted environment, which lacks
  the session's Qt/Wayland integration. Launched directly from the Hyprland
  session (inheriting `WAYLAND_DISPLAY`/`DISPLAY`/session D-Bus) it runs fine.
- **This session does not populate `graphical-session.target`**, so a systemd
  user service `WantedBy` that target would never auto-start anyway — the same
  reason Walker uses `exec-once` here. `exec-once` is therefore both the
  necessary and the working mechanism.
- The wrapper keeps the nix-store path out of the static `autostart.conf` (the
  package ships only a `libexec` binary, no `bin/`).

## Capabilities

### New Capabilities

- `hyprland-polkit-agent`: A polkit authentication agent runs in the Hyprland
  session so polkit-mediated authentication prompts (e.g. Bitwarden's system
  authentication / biometric unlock, and other privileged GUI actions) can be
  presented and satisfied — including via fingerprint, since `pam_fprintd` is
  first in the `polkit-1` PAM stack.

## Impact

- `modules/USERS/pim/programs/hyprland/default.nix`: add a `hyprpolkitagent-start`
  PATH wrapper (via `writeShellScriptBin`, execing
  `${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent`) to `home.packages`.
- `modules/USERS/pim/programs/hyprland/hypr/autostart.conf`: add
  `exec-once = hyprpolkitagent-start`.
- No system-level change required: `security.polkit.enable` and `services.fprintd`
  were already set; the gap was purely the missing session agent.
- Benefits all polkit-mediated GUI auth in the session, not just Bitwarden.

## Notes

- Bitwarden's "Unlock with system authentication" toggle appearing greyed out in
  Settings is separate and expected: Bitwarden greys it while the vault is
  locked / right after launch, and it is re-enabled once the vault is unlocked
  with the master password or PIN. The agent added here is what makes the
  lock-screen biometric *prompt* actually appear and succeed.
