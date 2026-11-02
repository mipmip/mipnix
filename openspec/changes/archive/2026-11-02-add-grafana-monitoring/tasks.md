## 1. Exporter on every node

- [x] 1.1 Add a NixOS module enabling `services.prometheus.exporters.node` on the node's `flake.nebulaNodes` address, port 9100, with the `systemd` collector and a unit include pattern for `restic-backups-.*`, `hip-repo-backup.*` and `syncthing.*`.
- [x] 1.2 Open 9100 on `networking.firewall.interfaces."nebula.mesh"` (only matters where the firewall is on).
- [x] 1.3 Import the module from `role-nebula-node`.

## 2. Prometheus and Grafana on dapperehaan

- [x] 2.1 Add `grafana-admin-password.age` to `secrets/secrets.nix` (pim, dapperehaan) and encrypt a random password into it (readable with `agenix -d`). Grafana also requires `security.secret_key`, so `grafana-secret-key.age` is added the same way.
- [x] 2.2 Add a NixOS module with `services.prometheus` (retention 90d, 30s interval) and one scrape job whose targets are every `<name>:9100` from `flake.nebulaNodes`.
- [x] 2.3 Configure `services.grafana` on `192.168.100.2:3000`, anonymous access off, admin password from the secret; order the unit after `nebula@mesh.service` as Backrest does.
- [x] 2.4 Provision the Prometheus data source.
- [x] 2.5 Provision the "Node Exporter Full" dashboard (grafana.com 1860) via `fetchurl` with a fixed hash.
- [x] 2.6 Write a backups dashboard JSON in the repository: unit state per host and time since last timer trigger; provision it.
- [x] 2.7 Import the module in dapperehaan's configuration.

- [x] 2.8 Add the `dapperehaan-grafana` restic dataset: `prepareCommand` writes `sqlite3 /var/lib/grafana/data/grafana.db ".backup /var/backups/restic/grafana.db"`, `cleanupCommand` removes it, keep daily 7, weekly 5, monthly 12.

## 3. Build and deploy

- [x] 3.1 `git add` new files; build dapperehaan, durer and one laptop.
- [x] 3.2 Deploy dapperehaan and durer with `rme deploy_remote`, and this laptop with `rme up_machine`.

## 4. Verify

- [x] 4.1 `curl http://durer:9100/metrics` from a mesh member succeeds; the same port on durer's public IP does not answer.
- [x] 4.2 Prometheus targets page lists every nebula node; deployed, running nodes are up.
- [x] 4.3 Grafana login works over nebula; an unauthenticated dashboard URL redirects to login.
- [x] 4.4 Host health dashboard shows dapperehaan's disk at about 77%.
- [x] 4.5 Backups dashboard lists dapperehaan's `restic-backups-dapperehaan-repos` and `hip-repo-backup` with their state.
- [x] 4.6 Run the `dapperehaan-grafana` restic backup once; the snapshot contains `grafana.db` and `sqlite3 grafana.db "PRAGMA integrity_check"` on a restored copy reports `ok`.
- [x] 4.7 Note which hosts still need a deploy before they appear as up.
