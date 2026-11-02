## Why

There is no overview of how the hosts are doing. A full disk, a stopped
restic timer or a failing `hip-repo-backup` is only noticed when someone
happens to look, as with the six failing repositories found by hand on
2026-11-02. dapperehaan is the backup hub, has 6 GB of free RAM and is
nearly idle, so it can also be the place where this is visible.

## What Changes

- Run Prometheus and Grafana on dapperehaan, reachable over nebula only
  (`192.168.100.2`), like Backrest.
- Run node-exporter on every nebula node, listening on its nebula address
  only. Prometheus derives its scrape targets from `flake.nebulaNodes`, so a
  new node is monitored without a second registration.
- Export the state of backup and sync units (restic backups,
  `hip-repo-backup`, syncthing) and their timers through node-exporter's
  systemd collector.
- Provision Grafana declaratively: the Prometheus data source, a host
  health dashboard and a backups dashboard, all from the repository.
- Back up Grafana's database to piethein as a new restic dataset,
  `dapperehaan-grafana`, dumped consistently with `sqlite3 .backup` first.
  The Prometheus metrics are not backed up.

## Capabilities

### New Capabilities

- `host-monitoring`: metrics collection from every nebula node, storage in
  Prometheus on dapperehaan, and Grafana dashboards for host health and
  backups.

### Modified Capabilities

- `host-backups`: the configured backup targets gain dapperehaan's
  `dapperehaan-grafana` dataset.

## Impact

- New NixOS modules for the exporter (imported via `role-nebula-node`) and
  for Prometheus plus Grafana (imported by dapperehaan).
- durer has its host firewall enabled, so the exporter port is opened on
  the `nebula.mesh` interface only.
- dapperehaan's restic `datasets` gains `dapperehaan-grafana`; the
  `flake.resticRepos` registry and Backrest pick it up.
- New agenix secret for the Grafana admin password (pim, dapperehaan).
- Disk on dapperehaan: Prometheus data for 11 nodes at 90 days retention,
  expected well under 5 GB.
