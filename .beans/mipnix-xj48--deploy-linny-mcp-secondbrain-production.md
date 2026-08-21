---
# mipnix-xj48
title: deploy linny-mcp in production for secondbrain (dapperehaan behind durer)
status: in-progress
type: task
priority: normal
created_at: 2026-08-21T00:00:00Z
updated_at: 2026-08-21T00:00:00Z
---

Run the linny-mcp server (github.com/linden-project/linny-mcp-server) in production
so it can securely serve github.com/mipmip/secondbrain.

Topology: Claude Online/Mobile → HTTPS secondbrain.pimsnel.com → durer (nginx TLS
terminate + ACME) → nebula mesh → dapperehaan linny-mcp bound to the mesh IP
192.168.100.2:8765. Bearer-token auth; hardened systemd unit from the upstream
NixOS module.

Decisions captured in the explore session:
- corpus at /var/lib/secondbrain (NOT /home — module sets ProtectHome=true)
- writable + bidirectional git-sync (GitHub as hub) via a RW deploy key
- quarantine kept on; readOnly=false
- ntfy alerts deferred → see [[mipnix-2dyz]]

Related: builds on the durer reverse-proxy pattern and the nebula mesh
(second-lighthouse work already landed).
