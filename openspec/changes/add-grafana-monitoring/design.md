## Context

Eleven hosts are nebula nodes, registered as plain strings in
`flake.nebulaNodes` and resolvable by name through `networking.extraHosts`.
Eight of them run restic backups to piethein. dapperehaan already serves one
nebula-only web UI (Backrest on `192.168.100.2:9898`) and has its host
firewall off; durer has it on with only public ports open. The only existing
monitoring is Uptime Kuma on hurry, which checks reachability, not health.

## Goals / Non-Goals

**Goals:**

- One place to see CPU, memory, disk, load and uptime of every node.
- One place to see whether each backup and sync unit last succeeded and
  when its timer last fired.
- Everything declared in the repository; a rebuilt dapperehaan comes back
  with the same data source and dashboards.

**Non-Goals:**

- Alerting and notifications. The dashboards come first; alerts can follow
  in a separate change once it is clear what is worth waking up for.
- Logs (Loki/Promtail).
- Public access or TLS. Access is over nebula only.
- Application metrics (nginx, Postgres, Tuwunel).

## Decisions

- **Prometheus pull, targets from `flake.nebulaNodes`.** The registry is
  already the single list of mesh members and carries plain strings, so
  reading it causes no evaluation cycle. Each node is scraped at
  `<name>:9100`. Laptops that are off show as down; that is expected and the
  dashboard shows it per host rather than hiding it.
- **Exporter in `role-nebula-node`.** Mesh membership is what makes a host
  scrapeable, so the exporter belongs with it and needs no per-host line.
- **Exporter binds the nebula address only.** `listenAddress` is the node's
  own `flake.nebulaNodes` entry. On hosts with a firewall, port 9100 is
  opened on `nebula.mesh` only. Metrics never reach the LAN or the internet.
- **Backups via the systemd collector.** node-exporter's `systemd` collector
  with a unit include pattern for `restic-backups-.*`, `hip-repo-backup.*`
  and `syncthing.*` reports unit state and timer last-trigger time. No
  textfile scripts and no change to the backup modules.
- **Grafana on `192.168.100.2:3000`, provisioned.** Data source and
  dashboards are provisioned from Nix, so edits in the UI are not the source
  of truth. Host health uses the community "Node Exporter Full" dashboard
  (grafana.com 1860) fetched by hash; the backups dashboard is a JSON file in
  the repository. Admin password from agenix; anonymous access off.
- **Back up Grafana's database, not the metrics.** `/var/lib/grafana/data/grafana.db`
  holds users, sessions and preferences; the dashboards and data source are
  already in the repository. A live SQLite file can be copied mid-write, so
  the dataset's `prepareCommand` writes a consistent copy with
  `sqlite3 grafana.db ".backup /var/backups/restic/grafana.db"` and
  `cleanupCommand` removes it, the same pattern as the database dumps on
  durer. Retention: daily 7, weekly 5, monthly 12. The Prometheus TSDB is
  left out: 90 days of metrics is cheap to lose and expensive to store
  again on piethein.
- **Retention 90 days.** Enough to see trends such as disk growth on
  dapperehaan; at 11 nodes and a 30 s interval the storage stays small.

## Risks / Trade-offs

- Prometheus runs on the host it also watches, so if dapperehaan is down
  the dashboards are too. Acceptable: Uptime Kuma on hurry still notices
  that dapperehaan is gone.
- Prometheus and Grafana state live on dapperehaan's `/`, already 77% used.
  Mitigation: fixed retention, and disk use is the first thing the
  dashboard shows.
- The unit include pattern must be kept in step with new backup units. A
  unit outside the pattern is simply invisible. Mitigation: the pattern
  matches by prefix, so new restic datasets are covered automatically.
- A deployed laptop that never joins the mesh shows as permanently down.

## Open Questions

- None blocking. The `host-backups` delta builds on the dapperehaan scenario
  that `add-github-repo-backup` adds, so that change is archived first.
