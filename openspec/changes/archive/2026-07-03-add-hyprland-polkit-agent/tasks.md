<!-- Backfilled: implementation already done and verified working. -->

## 1. Package + wrapper

- [x] 1.1 Add a `hyprpolkitagent-start` PATH wrapper to `home.packages` in
      `modules/USERS/pim/programs/hyprland/default.nix`, via
      `pkgs.writeShellScriptBin "hyprpolkitagent-start" "exec ${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent"`
      (the package ships only a `libexec` binary, so a wrapper gives a stable
      PATH name and keeps the store path out of the static config).

## 2. Autostart

- [x] 2.1 Add `exec-once = hyprpolkitagent-start` to
      `modules/USERS/pim/programs/hyprland/hypr/autostart.conf`, grouped with the
      other session services, with a comment documenting why it is NOT started
      via the systemd user unit (Qt6 SIGABRT under the unit environment; session
      does not populate `graphical-session.target`).

## 3. Verification

- [x] 3.1 Confirm no polkit agent was running before the change, and that
      `security.polkit.enable`, `services.fprintd`, enrolled prints, and
      `pam_fprintd` in `/etc/pam.d/polkit-1` were already present (so the agent
      was the only gap).
- [x] 3.2 Confirm the agent, launched from the session environment, stays alive
      and connects to the session bus (verified live: process persists and holds
      an `org.hyprland.hyprpolkitagent` connection).
- [x] 3.3 Confirm the systemd-unit start path crashes (SIGABRT / start-limit-hit)
      — documenting why `exec-once` direct launch is used instead.
- [x] 3.4 Confirm Bitwarden biometric/system-authentication unlock works: with
      the agent running, the lock-screen biometric prompt appears and the
      fingerprint unlock succeeds. (Confirmed working by the user.)
- [ ] 3.5 After `up_home` + re-login, confirm `hyprpolkitagent-start` auto-runs
      each session (the manual instance used to verify dies on logout; the
      rebuild makes it persistent). (User to confirm post-rebuild.)
