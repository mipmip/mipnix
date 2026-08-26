## Why

Backups run to the piethein NAS from every host (see the `host-backups`
capability), but there is no way to see what is actually stored or to restore a
file without dropping to a shell and running `restic` by hand against the right
repo. A web console — [Backrest](https://github.com/garethgeorge/backrest) — gives a
browse-and-restore view over all repositories. Tracks bean
[`mipnix-bx59`](../../../.beans/mipnix-bx59--install-httpsgithubcomemuellrestic-browser.md)
(originally scoped to the `restic-browser` desktop GUI; re-scoped to Backrest because
a browser-based UI on a server is the better fit).

dapperehaan is the natural host: it sits on the **same LAN as piethein**
(`192.168.2.22` ↔ `192.168.2.100`), so it reaches every repo directly over SFTP with
no nebula relay, and it already runs a nebula-bound, durer-fronted web service
(`linny-mcp`) that is the deployment template.

## What Changes

- Run Backrest as a hand-rolled hardened `systemd` service on dapperehaan (there is
  no `services.backrest` NixOS module), bound to the nebula IP `192.168.100.2:9898`,
  reachable only over the mesh at `http://dapperehaan:9898`. No public exposure.
- Pin restic (`BACKREST_RESTIC_COMMAND` → `pkgs.restic`) so Backrest never downloads
  its own binary.
- Enable Backrest's built-in login auth; the credentials come from an agenix secret,
  never a literal in a Nix option.
- **Viewer/restore only**: register every repository but create **no backup plans**,
  so Backrest never schedules backups that would collide with the existing NixOS
  restic timers.
- Aggregate every host's `mipnix.backup.piethein.datasets` into a flake-level
  registry, and generate Backrest's repo config from it so all repos are
  pre-registered on rebuild (declarative, zero click-ops). All repos share the one
  `restic-repo-pw` and the one `restic-ssh-key`.
- Make dapperehaan an agenix recipient of `restic-ssh-key.age` and
  `restic-repo-pw.age`; pin piethein's host key for the Backrest service user.

## Capabilities

### New Capabilities
- `backrest-restore-console`: A nebula-only Backrest web UI on dapperehaan for
  browsing and restoring restic snapshots across all piethein repositories, with
  login auth and no backup scheduling.

### Modified Capabilities
- `host-backups`: Adds a flake-level dataset registry so the full set of
  `(host, dataset, repo)` targets is enumerable off-host (consumed by the Backrest
  repo-config generator); no change to how backups run.

## Impact

- `modules/services/backup/restic-piethein.nix` (or a sibling) — expose the datasets
  as an aggregated `flake.*` registry.
- New Backrest module on dapperehaan (systemd unit, service user, nebula bind, auth,
  generated repo config) modeled on `modules/HOSTS/dapperehaan-server/linny-mcp.nix`.
- `secrets/secrets.nix` — add `dapperehaan` to `restic-ssh-key.age` /
  `restic-repo-pw.age` recipients; new `backrest-auth` secret. Requires a `rekey`.
- New dependency: `pkgs.backrest`.
- No change to the running backups, the NAS, or existing per-host restic timers.
- `peterspav`/`_lego2` and relay-only `harry` (no datasets) are naturally absent from
  the repo list.
