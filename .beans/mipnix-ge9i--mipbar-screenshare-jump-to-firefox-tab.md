---
# mipnix-ge9i
title: 'mipbar: screenshare jump to specific firefox tab'
status: scrapped
type: task
priority: low
created_at: 2026-05-05T10:00:00Z
updated_at: 2026-07-02T18:06:32Z
parent: mipnix-ecy2
---

When screensharing from Firefox, identify and jump to the specific tab that initiated the screenshare.

This requires a Firefox WebExtension that exposes the active screenshare tab via native messaging. The extension would communicate with mipbar to provide tab-level context.

Depends on mipnix-o7t0 (basic process-level screenshare identification) being completed first.
