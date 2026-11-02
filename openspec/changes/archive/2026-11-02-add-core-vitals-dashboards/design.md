## Context

Prometheus on dapperehaan scrapes node-exporter on every nebula node
(`up{job="node"}`, filesystem, memory, CPU, systemd units and timers), the
Nix textfile metrics (`nixos_system_generations` and friends) and piethein
over SNMPv3 (`raidStatus`, `sysUpTime`, `memTotalReal`, `memAvailReal`,
`memTotalSwap`, `hrStorageSize`/`hrStorageUsed`). Nothing checks whether a
public website answers. Dashboards are provisioned from
`modules/services/monitoring/dashboards/` through the `mipnix` provider.

## Goals / Non-Goals

**Goals:**

- One dashboard that shows the state of the core hosts, two public services
  and the backups without scrolling on a laptop screen.
- One table comparing the hosts on generations, disk, uptime, memory, swap
  and cores.

**Non-Goals:**

- Alerting. The tiles change colour; notifications remain a separate change.
- Checking every lobby service. The two named sites are a fixed list; deriving
  targets from the lobby registry can follow later.
- Checking content of the webshop; it is not live.

## Decisions

- **Blackbox exporter on dapperehaan, loopback only**, with an `http_2xx`
  module (HTTPS, follow redirects, IPv4 preferred). Prometheus scrapes it as
  job `blackbox` with the two URLs as targets and relabels `instance` to the
  URL. It yields `probe_success`, `probe_http_status_code`,
  `probe_duration_seconds` and `probe_ssl_earliest_cert_expiry`.
- **Host tiles from `up`.** NixOS hosts use `up{job="node",instance=...}`;
  piethein uses `up{job="piethein"}` combined with `raidStatus`, so a
  degraded RAID turns its tile red although the NAS answers.
- **Backup tile** shows two numbers: failed `restic-backups-*` and
  `hip-repo-backup` units, and timers whose last trigger is older than 26
  hours. Green only when both are zero.
- **Certificate thresholds:** orange below 14 days, red below 3 days.
  ACME renews at 30 days, so orange already means renewal is failing.
- **Host summary as one table** joined by instance, like the NixOS
  dashboard: root filesystem size and free space, `time() -
  node_boot_time_seconds`, memory used and total, swap used and total,
  `count(node_cpu_seconds_total{mode="idle"})` per host. piethein's row comes
  from SNMP metrics (volume from `hrStorage*`, uptime from `sysUpTime`,
  memory and swap from `mem*`, cores from `hrProcessorLoad`), with no
  generations.
- **`hrDevice` added to piethein's SNMP modules** for `hrProcessorLoad`;
  one series per core gives the count.

## Risks / Trade-offs

- A probe from dapperehaan measures the path from home to durer, not from
  visitors. Acceptable for "is it up".
- `raidStatus` values are Synology-specific (1 = normal). The tile treats
  anything else as degraded.
- The fixed host list in Core vitals must change when a core host is added
  or removed.

## Open Questions

- None.
