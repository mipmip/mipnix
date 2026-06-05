## Context

The Hyprland desktop module (`modules/programs/desktop/de/hyprland.nix`) sets
`environment.sessionVariables.ELECTRON_OZONE_PLATFORM_HINT = "wayland"` to hint Electron
apps toward the Wayland backend.

Investigation of the live system found the full screen-capture stack already present and
running:

- `xdg-desktop-portal` 1.20.4 (frontend) + `xdg-desktop-portal-hyprland` 1.3.12 + `-gtk`
- `pipewire`, `wireplumber`, `pipewire-pulse`
- `XDG_CURRENT_DESKTOP=Hyprland`, and `hyprland-portals.conf` routes ScreenCast to the
  `hyprland` backend
- `org.freedesktop.portal.ScreenCast` is exposed on the session bus

The Slack package is the NixOS-wrapped build (`slack-4.49.89`, Electron 41). Its wrapper:

```
exec slack ${NIXOS_OZONE_WL:+${WAYLAND_DISPLAY:+ \
  --ozone-platform-hint=auto \
  --enable-features=WaylandWindowDecorations,WebRTCPipeWireCapturer \
  --enable-wayland-ime=true}} "$@"
```

The flags — crucially `WebRTCPipeWireCapturer`, which enables PipeWire screen capture —
are only applied when `NIXOS_OZONE_WL` is set. That variable is not set in the session
(only `ELECTRON_OZONE_PLATFORM_HINT` is), so Slack runs without the capturer flag and its
screen-share attempt fails, surfacing the "give screen share access" message.

## Goals / Non-Goals

**Goals:**
- Enable working screen sharing for Slack on the Hyprland Wayland session.
- Use the standard NixOS mechanism (`NIXOS_OZONE_WL`) so the fix applies to all
  Electron/Chromium apps that gate their Wayland flags on it.

**Non-Goals:**
- Changing or repackaging Slack or any portal/PipeWire component (all already correct).
- Per-application flag overrides or `*-flags.conf` files.
- Touching `ELECTRON_OZONE_PLATFORM_HINT` (it stays; the two are complementary).

## Decisions

### Set `NIXOS_OZONE_WL = "1"` as a system session variable

Add `NIXOS_OZONE_WL = "1"` to the existing `environment.sessionVariables` block in
`modules/programs/desktop/de/hyprland.nix`.

**Why**: `NIXOS_OZONE_WL` is the convention NixOS Electron/Chromium wrappers check to
decide whether to inject Wayland flags (including the PipeWire screen capturer). It is the
documented, ecosystem-wide switch, so it fixes Slack and every similarly-wrapped app at
once with a single declarative line.

**Alternatives considered**:
- *Per-app `~/.config/slack-flags.conf`* — rejected: not declarative, Slack-specific, and
  duplicates what the wrapper already does when the env var is present.
- *Launch Slack from a wrapper with the flags inline* — rejected: bypasses the packaged
  wrapper, fragile across Slack updates, and doesn't help other Electron apps.
- *Switching the portal backend / installing more portals* — rejected: the portal stack is
  already correct and running; the gap is purely the missing env var on the app side.

### Keep it at the system (`environment.sessionVariables`) level

Place the variable next to the existing `ELECTRON_OZONE_PLATFORM_HINT` rather than in a
Home Manager session-variable set.

**Why**: The companion hint already lives there, the desktop session is system-managed via
GDM, and `environment.sessionVariables` is read at session start for all apps in the
graphical session. Keeping both vars together documents intent and avoids split ownership.

## Risks / Trade-offs

- **[Risk] Requires re-login to take effect** → `environment.sessionVariables` is evaluated
  at session start, so a NixOS rebuild alone won't apply it to the running session.
  *Mitigation*: rebuild with `up_machine`, then log out and back in (or reboot). For an
  immediate, non-permanent verification, relaunch Slack with `NIXOS_OZONE_WL=1 slack`.
- **[Risk] Behavior change for other Electron apps** → enabling the flags switches
  Electron apps to Wayland-native rendering, which could surface unrelated rendering
  quirks in some apps. *Mitigation*: this is the standard NixOS-recommended setting; apps
  already received the Wayland hint, so the delta is small and well-trodden.
- **[Trade-off] Global vs. targeted** → applies to all wrapped apps, not just Slack. This
  is intended (it's the correct general fix), but means the change is desktop-wide.

## Migration Plan

1. Add `NIXOS_OZONE_WL = "1"` to `environment.sessionVariables` in `hyprland.nix`.
2. Rebuild via `up_machine`.
3. Log out and back in (or reboot) so the session variable is loaded.
4. Verify: launch Slack, start a screen share, confirm the Hyprland window/screen picker
   appears and the share succeeds.

**Rollback**: remove the line and rebuild; re-login. No state migration involved.

## Open Questions

- None. Root cause is confirmed and the fix is a single session variable.
