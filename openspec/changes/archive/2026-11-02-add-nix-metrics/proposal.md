## Why

Grafana now shows CPU, disk and backups per host, but nothing about the NixOS
installation itself. Which mipnix commit a host runs, when it last switched,
whether it needs a reboot and how large its store has grown all have to be
looked up host by host. doornappel ran a configuration from 2026-10-09 with
an expired token for weeks before anyone noticed, and only durer collects
garbage, so store growth on the other hosts goes unseen.

## What Changes

- Set `system.configurationRevision` to the flake's git revision in
  `makeNixos`, so every system records the mipnix commit it was built from.
- Add an hourly job on every nebula node that writes NixOS facts to
  node-exporter's textfile collector: deployed revision, NixOS version,
  time of last switch, reboot needed, system and home-manager generation
  counts, and the closure size of the current system.
- Add a daily job for the expensive measurements: `/nix/store` size and
  path count.
- Include `nix-gc` in the systemd units node-exporter reports, so the last
  garbage collection shows where it is configured.
- Provision a "NixOS" dashboard in Grafana with one row per host.

## Capabilities

### New Capabilities

- `nix-metrics`: collection of NixOS and Nix store facts on every node and
  their presentation in Grafana.

### Modified Capabilities

- `host-monitoring`: node-exporter also serves the textfile collector, and
  its systemd unit pattern includes `nix-gc`.

## Impact

- `modules/nix/helpers.nix` (`makeNixos`): one line for
  `configurationRevision`. Every host's system derivation changes once.
- `modules/services/monitoring/node-exporter.nix`: textfile collector, the
  two collection jobs, `nix-gc` in the unit pattern.
- `modules/services/monitoring/grafana.nix` and a new
  `dashboards/nixos.json`.
- Measurement load: the hourly job only reads symlinks and runs
  `nix path-info` once; the daily `du` over `/nix/store` takes minutes on a
  large store and runs at low priority.
