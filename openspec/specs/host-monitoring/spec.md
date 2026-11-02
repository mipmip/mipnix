# host-monitoring Specification

## Purpose
Show the health of every nebula node and the state of backups and sync in
Grafana on dapperehaan, from metrics collected over the mesh.

## Requirements

### Requirement: Every nebula node exports metrics on the mesh

Every host that is a nebula node SHALL run node-exporter, listening on its
own nebula address on port 9100 and on no other address. On hosts with a
host firewall, the port SHALL be open on the `nebula.mesh` interface only.

#### Scenario: Metrics reachable over nebula

- **WHEN** a client on the mesh requests `http://<node>:9100/metrics`
- **THEN** it receives node-exporter metrics

#### Scenario: Not reachable outside the mesh

- **WHEN** a client requests port 9100 on durer's public address or on a
  host's LAN address
- **THEN** the connection is refused or not answered

### Requirement: Scrape targets follow the nebula registry

Prometheus on dapperehaan SHALL scrape every node in `flake.nebulaNodes`
and no host outside it, without a second list of hosts.

#### Scenario: New node joins the mesh

- **WHEN** a host is added to `flake.nebulaNodes` and both it and dapperehaan
  are deployed
- **THEN** Prometheus scrapes that host with no other configuration change

#### Scenario: Node is offline

- **WHEN** a node is switched off
- **THEN** its target is reported as down and the other targets are
  unaffected

### Requirement: Backup and sync unit state is collected

node-exporter SHALL report the state of every `restic-backups-*`,
`hip-repo-backup`, `syncthing` and `nix-gc` unit on its host, and the last
trigger time of their timers.

#### Scenario: Failed backup

- **WHEN** a restic backup or `hip-repo-backup` run ends in the failed state
- **THEN** that unit shows as failed in Prometheus for that host

#### Scenario: Timer stopped firing

- **WHEN** a backup timer has not fired for longer than its interval
- **THEN** its last trigger time in Prometheus shows how long ago it ran

#### Scenario: Garbage collection

- **WHEN** a host has `nix.gc` enabled and its timer fires
- **THEN** the last trigger time of `nix-gc.timer` is in Prometheus

### Requirement: Grafana is reachable over nebula only

Grafana SHALL listen on `192.168.100.2:3000` only, require a login, and
take its admin password from an agenix secret.

#### Scenario: Opening Grafana from a laptop on the mesh

- **WHEN** pim opens `http://192.168.100.2:3000` from a mesh member
- **THEN** Grafana shows its login page and accepts the admin credentials

#### Scenario: Anonymous access

- **WHEN** a request without a session reaches a dashboard URL
- **THEN** Grafana redirects to the login page

### Requirement: Data source and dashboards are provisioned

The Prometheus data source, a host health dashboard and a backups dashboard
SHALL be provisioned from the repository, so a rebuilt dapperehaan shows the
same dashboards with no manual step.

#### Scenario: Host health dashboard

- **WHEN** pim opens the host health dashboard
- **THEN** CPU, memory, disk use, load and uptime are shown per node

#### Scenario: Backups dashboard

- **WHEN** pim opens the backups dashboard
- **THEN** each backup and sync unit is listed per host with its current
  state and the time its timer last fired

#### Scenario: Rebuilt host

- **WHEN** dapperehaan's Grafana state directory is empty after a rebuild
- **THEN** the data source and both dashboards are present after startup

### Requirement: Metrics retention

Prometheus SHALL keep metrics for 90 days.

#### Scenario: Trend over weeks

- **WHEN** pim views disk use for dapperehaan over the last 60 days
- **THEN** the full period is shown

### Requirement: Grafana state is backed up

Grafana's database SHALL be backed up to piethein as the restic dataset
`dapperehaan-grafana`, from a consistent copy made with SQLite's backup
command before each run. Prometheus metrics SHALL NOT be backed up.

#### Scenario: Restoring Grafana

- **WHEN** dapperehaan is rebuilt and `grafana.db` is restored from the
  latest `dapperehaan-grafana` snapshot
- **THEN** Grafana starts with the same users and preferences as before

#### Scenario: Backup taken while Grafana writes

- **WHEN** the backup runs while Grafana is writing to its database
- **THEN** the backed-up copy passes `PRAGMA integrity_check`
