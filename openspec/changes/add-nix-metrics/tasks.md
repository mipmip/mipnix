## 1. Revision

- [x] 1.1 In `makeNixos`, set `system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null`.

## 2. Collection

- [x] 2.1 Enable node-exporter's `textfile` collector with a directory under `/var/lib`, created by systemd tmpfiles.
- [x] 2.2 Add an hourly root oneshot and timer that writes `nixos.prom` (info, switch time, reboot required, generation counts, closure size) via a temporary file and `mv`.
- [x] 2.3 Add a daily oneshot and timer (`Nice=19`, `IOSchedulingClass=idle`, `RandomizedDelaySec`) that writes `nix-store.prom` (store size, path count) the same way.
- [x] 2.4 Add `nix-gc` to the systemd unit include pattern.

## 3. Dashboard

- [x] 3.1 Write `dashboards/nixos.json`: a per-host table (revision, version, switch age, reboot, generations, closure, store size, last GC) and a store size graph.
- [x] 3.2 Provision it next to the other dashboards.

## 4. Build and deploy

- [x] 4.1 Build dapperehaan, durer, delliebellie and one Pi.
- [x] 4.2 Deploy dapperehaan, durer, harry and hurry with `rme deploy_remote`, and this laptop with `rme up_machine`.

## 5. Verify

- [x] 5.1 `nixos-version --json` on a deployed host reports the deployed commit.
- [x] 5.2 Prometheus has `nixos_system_info` and `nixos_system_generations` for every deployed host.
- [x] 5.3 Start the daily store job by hand on one host; `nix_store_size_bytes` appears.
- [x] 5.4 The NixOS dashboard lists the deployed hosts and durer's last GC.
