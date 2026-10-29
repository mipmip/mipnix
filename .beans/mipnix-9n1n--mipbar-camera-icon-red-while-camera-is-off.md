---
# mipnix-9n1n
title: 'mipbar: camera icon red while camera is off'
status: in-progress
type: bug
created_at: 2026-10-29T12:02:14Z
updated_at: 2026-10-29T12:03:37Z
---

The camera indicator shows while no camera is in use. WirePlumber keeps an Intel IPU6 capture device (/dev/video16) open, and the lsof check counts that as camera use.

Ignoring WirePlumber and PipeWire in lsof causes false negatives: on IPU6/MIPI cameras every app reaches the camera through PipeWire/libcamera, so real use would never show.

Wanted:
- Detect camera use through PipeWire (camera-backed Video/Source in state running, libcamera or v4l2) plus lsof for direct /dev/video access, ignoring pipewire and wireplumber.
- Screencast sources must not trigger the camera icon.
- Tooltip lists all apps using the camera.
- Click with one app focuses it; with several apps a menu lists them and focuses the chosen one.

Related: mipnix-h24f
