---
# mipnix-klaa
title: cloudflared tunnels give up permanently after a boot-time DNS race
status: todo
type: bug
priority: high
tags:
    - nix
    - networking
created_at: 2026-09-14T19:36:11Z
updated_at: 2026-09-14T19:36:11Z
---

`vaultwarden.notnix.com` was down for over a day and returned Cloudflare 530
with `error code: 1033`. The cause was not DNS being broken, not vaultwarden,
and not Cloudflare. It was one minute of bad luck at boot plus a restart policy
that gives up for good.

What the journal on hurry shows:

    13 sep 16:01   hurry boots
    13 sep 16:02   cloudflared: lookup _v2-origintunneld._tcp.argotunnel.com
                   on [::1]:53: read: connection refused
                   Scheduled restart job, restart counter is at 8.
                   Start request repeated too quickly -> start-limit-hit
                   systemd stops trying, permanently

`/etc/resolv.conf` now lists `192.168.2.254`, not `[::1]`, so the localhost
resolver in that error was a transient state during boot: cloudflared started
before resolvconf had written the real nameservers. DNS came up seconds later
and has worked ever since. Nothing retried, so the tunnel stayed down while
`vaultwarden.service` sat there `active` the whole time.

The fix is the restart policy, not the ordering alone. Ordering can always lose
a race; a unit that depends on the network coming up should back off and keep
trying instead of burning eight attempts in a burst and quitting. Give the
tunnel units a `RestartSec` long enough that the burst window cannot be
exhausted by a transient failure, or raise `StartLimitIntervalSec` so a slow
retry is not counted as a loop.

Recovery after the limit is hit needs `systemctl reset-failed` before
`systemctl start`. A plain restart does nothing, which is worth knowing when
this happens again.

Scope: `services.cloudflared` on hurry (tunnel `4a8ebfc1`) and the same config
on harry (tunnel `bb0a3af1`). Note that harry's `_cloudflared.nix` is not
actually active: the leading underscore makes import-tree skip it, and
`configuration.nix` does not import it either, so harry has no cloudflared unit
and no binary, and has been running a generation from 17 March. That is a
separate problem from this one.

This is not an argument for keeping Cloudflare or for replacing it. A relay
hosted on durer would inherit exactly the same fragility, because the failure is
in how the unit retries, not in whose relay it dials. Fix this first, then have
the Cloudflare conversation on its own merits.

Diagnostic trap worth recording: `dig` is not installed on these Pis. A check
that wraps it in a conditional reports "no answer" for a missing command just as
it would for a real timeout, which is how the first diagnosis of this incident
went wrong. Use `host` or `getent ahosts`, and note that `argotunnel.com` has no
A record at all, so `getent hosts argotunnel.com` fails even when DNS is
perfectly healthy.
