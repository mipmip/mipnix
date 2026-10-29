---
# mipnix-4s6t
title: 'firefox: use PipeWire for the camera'
status: completed
type: bug
created_at: 2026-10-29T12:20:12Z
updated_at: 2026-10-29T13:33:00Z
openspec-link: openspec/changes/archive/2026-10-29-firefox-pipewire-camera
---

On delliebellie (Intel IPU6 camera) Firefox opens the raw IPU6 devices /dev/video0 to /dev/video31 directly over V4L2. Jitsi Meet shows a long list of identical devices and no preview, and Firefox keeps /dev/video0 open after the tab is closed.

The IPU6 camera only works through libcamera in PipeWire. Setting media.webrtc.camera.allow-pipewire = true makes Firefox use the PipeWire camera.

Set it for all computers, so every machine uses the same camera path. Verify on one computer with a USB webcam that the camera still works.

Related: mipnix-9n1n
