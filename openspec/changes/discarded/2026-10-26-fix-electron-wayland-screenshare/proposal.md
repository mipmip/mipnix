## Why

Screen sharing in Slack fails with "Please check your system preferences to give screen
share access to Slack." On Wayland there is no OS-level screen-share permission toggle;
the message is Slack reporting a failed screen-capture attempt.

Diagnosis found **two** independent gaps, both required for a working share:

1. **Missing Wayland flags.** The NixOS Slack wrapper only injects its Wayland
   screen-capture flags (`--enable-features=WaylandWindowDecorations,WebRTCPipeWireCapturer`,
   `--ozone-platform-hint=auto`) when `NIXOS_OZONE_WL` is set, and it was unset — so Slack
   launched without the PipeWire capturer.

2. **Portal authorization blocked by `ptrace_scope` (the real blocker).** After setting
   `NIXOS_OZONE_WL=1`, Slack was verified running Wayland-native with the capturer flag and
   *did* call `org.freedesktop.portal.ScreenCast` — but the portal refused the session:

   ```
   Failed to request session: org.freedesktop.DBus.Error.AccessDenied:
   Portal operation not allowed: Unable to open /proc/<pid>/root
   ```

   To identify the caller, the portal opens `/proc/<caller-pid>/root` (to read
   `.flatpak-info`). This failed even after setting `kernel.yama.ptrace_scope = 0` and
   restarting the portal — so Yama was not the (sole) cause. The remaining factor is the
   **dbus implementation**: the system runs `dbus-broker` (the NixOS 26.05 default), and
   `xdg-desktop-portal`'s caller-verification `/proc/<pid>/root` open fails under
   dbus-broker in a way it does not under the reference `dbus-daemon` — a known interaction
   reported across distros for both ScreenCast and file-chooser portals. Switching to the
   reference dbus-daemon (`services.dbus.implementation = "dbus"`) restores the portal's
   ability to authorize the request. `ptrace_scope = 0` is kept as a complementary enabler
   (the portal genuinely needs `/proc/<pid>/root` access), but the dbus implementation is
   the decisive fix.

The portal stack (`xdg-desktop-portal-hyprland`, `-gtk`, PipeWire, WirePlumber) was already
correct and running throughout; no portal/PipeWire/Slack package change is needed.

## What Changes

- Add `NIXOS_OZONE_WL = "1"` to `environment.sessionVariables` in the Hyprland desktop
  module, alongside the existing `ELECTRON_OZONE_PLATFORM_HINT = "wayland"`, so NixOS
  Electron/Chromium wrappers inject their Wayland flags (incl. the PipeWire capturer).
- Set `services.dbus.implementation = "dbus"` (reference dbus-daemon instead of the default
  dbus-broker) so `xdg-desktop-portal` can verify the caller and authorize ScreenCast — the
  decisive fix for the `Unable to open /proc/<pid>/root` denial.
- Set `boot.kernel.sysctl."kernel.yama.ptrace_scope" = 0` as a complementary enabler for
  the portal's `/proc/<pid>/root` access.

## Capabilities

### New Capabilities

- `electron-wayland-screenshare`: Ensure Electron/Chromium applications on the Hyprland
  Wayland session can screen-share through the desktop portal — both by running with the
  NixOS Wayland flags required for the PipeWire capturer, and by allowing the portal to
  authorize the ScreenCast request (`ptrace_scope = 0`).

### Modified Capabilities

<!-- None: no existing spec's requirements change. -->

## Impact

- `modules/programs/desktop/de/hyprland.nix`: add `NIXOS_OZONE_WL = "1"` to
  `environment.sessionVariables`, and `boot.kernel.sysctl."kernel.yama.ptrace_scope" = 0`.
- Affects all Electron/Chromium apps in the Hyprland session for Wayland rendering and
  screen capture; `ptrace_scope = 0` also unblocks portal-mediated file choosers etc. for
  any sandboxed-verified caller.
- **Security trade-off:** `ptrace_scope = 0` permits any same-user process to ptrace
  another same-user process (intra-user only; no cross-user or root impact) — the standard
  desktop setting for portal screen capture.
- Requires a NixOS rebuild (`up_machine`) and a re-login (`environment.sessionVariables` is
  read at session start; the sysctl applies at boot/rebuild).
