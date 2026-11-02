## 1. Collection

- [x] 1.1 Enable `services.prometheus.exporters.blackbox` on dapperehaan on 127.0.0.1 with an `http_2xx` module (HTTPS, follow redirects, prefer IPv4).
- [x] 1.2 Add a `blackbox` scrape job (60s) for `https://umami.pimsnel.com` and `https://studio-mint.shop`, relabelling `instance` to the URL.
- [x] 1.3 Add `hrDevice` to piethein's SNMP modules.

## 2. Dashboards

- [x] 2.1 Write `dashboards/core-vitals.json`: host tiles (`up`, piethein with `raidStatus`), service tiles (probe success, status, duration, certificate days), backups tile (failed units, stale timers).
- [x] 2.2 Write `dashboards/host-summary.json`: one joined table per host (generations, disk size/free, uptime, memory, swap, cores) plus piethein from SNMP.
- [x] 2.3 Provision both next to the existing dashboards.

## 3. Deploy and verify

- [x] 3.1 Build and deploy dapperehaan.
- [x] 3.2 Prometheus shows `probe_success` 1 for both sites and a certificate expiry in the future.
- [x] 3.3 `hrProcessorLoad` exists for piethein.
- [x] 3.4 Core vitals shows all six hosts, both sites and the backups tile; Host summary lists every host with its columns.
