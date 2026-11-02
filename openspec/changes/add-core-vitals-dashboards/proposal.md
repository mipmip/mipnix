## Why

Grafana has detailed dashboards (Node Exporter Full, Backups, NixOS,
Synology), but no page that answers "is everything fine?" at a glance, and
no compact comparison of the hosts side by side. Checking the core machines,
the public services and the backups now means opening several dashboards.

## What Changes

- Add a "Core vitals" dashboard: one tile per core host (durer, harry,
  hurry, dapperehaan, piethein, peterspav), tiles for umami and the
  studio-mint webshop (status, response time, TLS certificate expiry), and
  one tile summarising all backups.
- Add a "Host summary" dashboard: one row per host with Nix generations,
  disk size and free space, uptime, memory, swap and cores.
- Run a Prometheus blackbox exporter on dapperehaan that checks
  `https://umami.pimsnel.com` and `https://studio-mint.shop` over HTTPS every
  minute.
- Add the `hrDevice` SNMP module for piethein so its core count is known.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `host-monitoring`: gains HTTP checks of public services and the two
  dashboards.

## Impact

- `modules/services/monitoring/`: blackbox exporter and its scrape job in
  the Grafana module, two new dashboard JSON files, `hrDevice` added to the
  piethein SNMP modules.
- dapperehaan only; no other host changes.
- The webshop at studio-mint.shop is not live yet. Its tile checks
  reachability and the certificate only, so it needs no change when the
  shop launches.
