## Why

On delliebellie, whose Intel IPU6 camera only works through libcamera in PipeWire, Firefox opens the raw IPU6 devices (`/dev/video0` to `/dev/video31`) directly. Jitsi Meet then shows a long list of identical cameras and no preview, and Firefox keeps `/dev/video0` open after the tab is closed.

Related task: [mipnix-4s6t](../../../.beans/mipnix-4s6t--firefox-use-pipewire-for-the-camera.md)

## What Changes

- Set the Firefox pref `media.webrtc.camera.allow-pipewire = true` in the default profile, on every computer that uses the `pim-firefox` home-manager module.
- Firefox then uses the PipeWire camera: one entry per real camera, a working preview on IPU6 laptops, and the camera released when the page stops using it.

## Capabilities

### New Capabilities

- `firefox-camera`: how Firefox reaches cameras on Pim's computers.

### Modified Capabilities

None.

## Impact

- **Modified files**: `modules/USERS/pim/programs/firefox.nix`.
- **Hosts**: every host with the `pim-firefox` module. IPU6 laptops get a working camera; hosts with a USB webcam move from direct V4L2 to PipeWire for the same camera.
- **Related**: makes Firefox camera use visible to the mipbar camera indicator through PipeWire (change `mipbar-camera-pipewire-detection`).
