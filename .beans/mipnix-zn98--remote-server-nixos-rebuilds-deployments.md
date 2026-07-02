---
# mipnix-zn98
title: remote server nixos-rebuilds deployments
status: completed
type: task
priority: normal
created_at: 2026-06-09T08:30:12Z
updated_at: 2026-07-02T07:34:13Z
---

okay, we have reached the moment we cannot run `nixos-rebuild switch` and
`home-manager switch` on our servers. Main reasons are remote disk space which
is scarse and high cpu load which is specially a problem on rasberry pi's.

# Requirement new method
