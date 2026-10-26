## 1. Configuration change

- [x] 1.1 In `modules/programs/desktop/de/hyprland.nix`, add `NIXOS_OZONE_WL = "1";` to the existing `environment.sessionVariables` block (alongside `ELECTRON_OZONE_PLATFORM_HINT = "wayland";`)
- [x] 1.2 In the same module, add `boot.kernel.sysctl."kernel.yama.ptrace_scope" = 0;` as a complementary enabler for the portal's `/proc/<pid>/root` access.
      → During verification, with `NIXOS_OZONE_WL` set, Slack *did* call the portal but got `AccessDenied: … Unable to open /proc/<pid>/root`. Setting `ptrace_scope=0` (and restarting the portal) did NOT resolve it, so Yama was not the (sole) cause — see 1.3.
- [x] 1.3 In `modules/programs/desktop/system/services.nix`, set `services.dbus.implementation = "dbus";` (reference dbus-daemon instead of the NixOS 26.05 default dbus-broker).
      → The decisive fix: the `/proc/<pid>/root` denial is a known dbus-broker + xdg-desktop-portal interaction (caller verification); the reference dbus-daemon passes caller credentials as the portal expects. Verified in the built lego2 config: `services.dbus.implementation = "dbus"`, `ptrace_scope = 0`, `NIXOS_OZONE_WL = "1"`.

## 2. Deploy

- [ ] 2.1 Rebuild the system with `up_machine`  (user action — needs the machine)
- [ ] 2.2 REBOOT (the dbus implementation switch changes the session/system bus; a full reboot is the clean way to bring up dbus-daemon + a fresh portal)

## 3. Verification

- [ ] 3.1 Confirm `NIXOS_OZONE_WL` is set in the session (freshly-launched terminal env)
      → Pre-verified in the built config (`environment.sessionVariables.NIXOS_OZONE_WL = "1"`). Live session check needs re-login.
- [ ] 3.2 Confirm a freshly-launched Slack includes `--enable-features=...WebRTCPipeWireCapturer`
      → Confirmed live: Slack launched with `NIXOS_OZONE_WL=1` runs Wayland-native (`xwayland: false`) with `--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations,WebRTCPipeWireCapturer`.
- [ ] 3.3 Confirm `kernel.yama.ptrace_scope` is `0` in the running system (`sysctl kernel.yama.ptrace_scope`)
      → Was `1` (systemd/NixOS default) during diagnosis — the actual blocker. Set to `0` in config; confirm after rebuild.
- [ ] 3.4 Confirm the session bus is dbus-daemon after reboot (`ps -u $USER -o comm | grep -i dbus` shows `dbus-daemon`, not `dbus-broker`).
- [ ] 3.5 Start a screen share in Slack: confirm the Hyprland picker appears and sharing works, and the console shows no `Unable to open /proc/<pid>/root` error  (user action — live test).
