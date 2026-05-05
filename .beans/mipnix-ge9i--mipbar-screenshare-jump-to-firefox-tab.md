---
# mipnix-ge9i
title: 'mipbar: screenshare jump to specific firefox tab'
status: draft
type: task
priority: low
created_at: 2026-05-05T10:00:00Z
updated_at: 2026-05-05T10:00:00Z
---

When screensharing from Firefox, identify and jump to the specific tab that initiated the screenshare.

This requires a Firefox WebExtension that exposes the active screenshare tab via native messaging. The extension would communicate with mipbar to provide tab-level context.

Depends on mipnix-o7t0 (basic process-level screenshare identification) being completed first.
