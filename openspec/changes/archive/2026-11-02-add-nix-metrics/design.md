## Context

node-exporter runs on every nebula node through `role-nebula-node`, and
Prometheus on dapperehaan scrapes all of them. node-exporter's textfile
collector reads `*.prom` files from a directory, so host-specific facts can
be exported without a new service or port. `nixos-version --json` already
reports the NixOS version and nixpkgs revision, and reports the
configuration revision once `system.configurationRevision` is set, which
mipnix does not do yet.

## Goals / Non-Goals

**Goals:**

- Per host: deployed mipnix revision, NixOS version, nixpkgs revision, time
  since last switch, reboot needed, generation counts, closure size, store
  size and path count.
- Last garbage collection, where `nix.gc` is configured.
- A dashboard that shows these side by side for all hosts.

**Non-Goals:**

- Computing how many commits a host is behind `main`. Prometheus does not
  know `main`; the dashboard shows the revision and the switch age, which is
  enough to spot a stale host.
- Enabling `nix.gc` on more hosts. The dashboard makes the gap visible;
  closing it is a separate decision.
- Non-NixOS machines (ng-macbook, nix-on-droid).

## Decisions

- **Textfile collector, two jobs.** An hourly root oneshot writes
  `nixos.prom`; a daily oneshot with `Nice=19` and `IOSchedulingClass=idle`
  writes `nix-store.prom`. Each writes to a temporary file and renames it,
  so node-exporter never reads half a file. Separate files mean the slow
  `du` never delays the cheap metrics.
- **Metrics:**

  | Metric                                   | Source                                                        |
  |------------------------------------------|---------------------------------------------------------------|
  | `nixos_system_info{revision,version,nixpkgs}` = 1 | `nixos-version --json`                               |
  | `nixos_system_switch_timestamp_seconds`  | mtime of `/nix/var/nix/profiles/system`                       |
  | `nixos_reboot_required`                  | `/run/booted-system` vs `/run/current-system`: kernel, initrd, kernel-modules |
  | `nixos_system_generations`               | count of `system-*-link` in `/nix/var/nix/profiles`           |
  | `nixos_home_manager_generations{user}`   | count of `home-manager-*-link` in each user's state profiles  |
  | `nixos_system_closure_bytes`             | `nix path-info -S /run/current-system`                        |
  | `nix_store_size_bytes`                   | `du -sb /nix/store` (daily)                                   |
  | `nix_store_paths`                        | entries in `/nix/store` (daily)                               |

- **Revision from the flake.** `makeNixos` sets
  `system.configurationRevision = self.rev or self.dirtyRev or null`. A build
  from a dirty tree shows a `-dirty` revision, which is itself useful to see.
- **`nix-gc` through the existing systemd collector.** Adding it to the unit
  include pattern reuses the timer-last-trigger metric the backups dashboard
  already uses; no textfile entry is needed.
- **Dashboard as a table per host**, plus a store size graph over time.
  Colours flag a switch older than 14 days and a pending reboot.

## Risks / Trade-offs

- `du` over a large store costs I/O once a day. Mitigation: idle I/O class
  and lowest CPU priority, at a randomized time.
- Setting `configurationRevision` changes every system derivation, so every
  host rebuilds once. After that it changes only with new commits, which
  already cause a rebuild.
- A revision label on an info metric creates a new series per commit. At a
  few commits a day across ten hosts that is negligible for Prometheus.

## Open Questions

- None blocking. The `host-monitoring` delta modifies a spec that
  `add-grafana-monitoring` creates, so that change (and before it
  `add-github-repo-backup`) is archived first.
