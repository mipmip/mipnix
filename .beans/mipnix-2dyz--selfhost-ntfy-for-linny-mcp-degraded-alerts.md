---
# mipnix-2dyz
title: self-host ntfy for linny-mcp degraded-mode alerts
status: todo
type: task
priority: normal
created_at: 2026-08-21T00:00:00Z
updated_at: 2026-08-21T00:00:00Z
---

Deferred from the linny-mcp production deployment (dapperehaan behind durer).

linny-mcp's `ntfyTopicURL` option drives degraded-mode alerts — e.g. when
bidirectional git-sync of `/var/lib/secondbrain` hits a hard conflict and stops,
or the corpus goes read-only. Per the linny docs these alerts go to the phone and
are **never** written into the corpus.

For the initial production deploy `ntfyTopicURL` is left `null` (no alerts).

Scope for this task:
- Stand up a self-hosted ntfy service (candidate host: durer, which already runs
  nginx + ACME, or dapperehaan).
- Expose a topic (e.g. `https://ntfy.pimsnel.com/linny-mcp`) with auth.
- Wire `services.linny-mcp.ntfyTopicURL` to it and confirm degraded-mode alerts
  reach the phone (git-sync conflict = primary trigger to test).
- Consider reusing the same ntfy for other home-infra alerts (restic failures, etc.).
