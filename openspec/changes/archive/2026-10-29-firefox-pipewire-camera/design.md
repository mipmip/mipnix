## Context

See proposal.md for why. `modules/USERS/pim/programs/firefox.nix` defines one profile, `default`, with `settings = defaultSettings // { }`. Without the pref, Firefox enumerates `/dev/video*` itself over V4L2.

## Decisions

### 1. Profile setting, not a policy

**Decision**: Add `"media.webrtc.camera.allow-pipewire" = true` to `defaultSettings`, so any future profile gets it too.

**Alternative considered**: a `Preferences` entry in `extraPolicies`. That locks the pref for all profiles, which is stronger than needed and makes testing the old behavior in `about:config` impossible.

### 2. All computers

**Decision**: No per-host switch. PipeWire exposes USB webcams as well, so one path works everywhere and the mipbar camera indicator sees every Firefox camera user.

## Risks / Trade-offs

- **[Camera portal]** Firefox asks for the camera through xdg-desktop-portal. If a host has no working portal, the camera is missing in Firefox. → Verify on one host with a USB webcam before archiving.
- **[Existing Firefox session]** The pref only applies after a Firefox restart. → Restart Firefox after the home-manager switch.

## Migration Plan

Switch home-manager, restart Firefox. Rollback is reverting the commit and restarting Firefox.
