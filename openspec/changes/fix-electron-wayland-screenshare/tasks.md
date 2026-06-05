## 1. Configuration change

- [ ] 1.1 In `modules/programs/desktop/de/hyprland.nix`, add `NIXOS_OZONE_WL = "1";` to the existing `environment.sessionVariables` block (alongside `ELECTRON_OZONE_PLATFORM_HINT = "wayland";`)

## 2. Deploy

- [ ] 2.1 Rebuild the system with `up_machine`
- [ ] 2.2 Log out and back in (or reboot) so the new session variable is loaded

## 3. Verification

- [ ] 3.1 Confirm `NIXOS_OZONE_WL` is set in the session (e.g. it appears in a freshly-launched terminal's environment)
- [ ] 3.2 Confirm a freshly-launched Slack process includes `--enable-features=...WebRTCPipeWireCapturer` in its command line
- [ ] 3.3 Start a screen share in Slack and confirm the Hyprland screen/window picker appears and sharing works (no "give screen share access" message)
- [ ] 3.4 (Optional, pre-deploy sanity) Verify the fix live without rebuilding by relaunching Slack as `pkill slack; NIXOS_OZONE_WL=1 slack` and testing screen share
