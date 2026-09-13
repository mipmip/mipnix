---
# mipnix-1j15
title: mipbar displays menu with per-monitor info and resolution switching
status: completed
openspec-link: openspec/changes/archive/2026-09-13-add-mipbar-displays-menu
type: feature
priority: normal
tags:
    - mipbar
created_at: 2026-09-13T14:52:48Z
updated_at: 2026-09-13T15:13:06Z
---

A dedicated Displays menu in mipbar showing every attached monitor with full
detail (model, size, resolution, refresh, scale, logical size, DPI, position,
connector/port, active workspace) and letting me switch the resolution per
monitor at runtime.

Runtime only — no Hyprland config is written; a "Reset to configured" action
restores the declarative state via `hyprctl reload`.

Also retires nwg-displays, which breaks things and cannot write its config
anyway (monitors.conf is a read-only Nix store symlink).
