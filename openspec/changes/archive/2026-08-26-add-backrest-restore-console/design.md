## Context

Every host backs up to the piethein NAS via the `host-backups` capability
(`modules/services/backup/restic-piethein.nix`): each dataset is its own repo at
`sftp:resticbackup@192.168.2.100:/ResticBackups/<host>-<dataset>`, all sharing one
repo password (`restic-repo-pw`) and one SSH key (`restic-ssh-key`), with piethein's
host key pinned. There is no viewer/restore UI.

dapperehaan is on the piethein LAN (`deploy.nix` → `192.168.2.22`) so it reaches the
NAS directly over SFTP — no relay, unlike durer which tunnels through Pis
(`proxyJump = [ "192.168.100.6" "192.168.100.7" ]`). It is a nebula node
(`192.168.100.2`), always-on, and already hosts a nebula-bound web service fronted by
durer (`linny-mcp.nix` + `durer-server/secondbrain.nix`) — the deployment template.

`pkgs.backrest` exists but there is **no `services.backrest` NixOS module** in the
pinned nixpkgs, so the unit is hand-rolled. Chosen decisions from exploration:
nebula-only exposure, and declarative repo config generated from an aggregated
dataset registry (not click-ops).

## Goals / Non-Goals

**Goals:**
- Browse snapshots and restore files across all piethein repos from one web UI.
- Nebula-only, authenticated, no public surface.
- Repos pre-registered declaratively from the existing dataset definitions.
- Zero interference with the running NixOS restic backup timers.

**Non-Goals:**
- Backrest taking over backup scheduling (the NixOS timers remain the source of
  truth for creating snapshots).
- Public exposure via durer nginx (possible later; out of scope now).
- The `emuell/restic-browser` desktop GUI named in the bean (re-scoped to Backrest).
- Any change to piethein, the shared credentials' meaning, or per-host retention.

## Decisions

### Hand-rolled systemd unit modeled on linny-mcp

No `services.backrest` module exists, so define `systemd.services.backrest` with a
dedicated service user, `StateDirectory`, and hardening mirroring `linny-mcp.nix`.
Configure Backrest by environment: `BACKREST_PORT`/bind to `192.168.100.2:9898`,
`BACKREST_CONFIG` + `BACKREST_DATA` under the state dir, and
`BACKREST_RESTIC_COMMAND=${pkgs.restic}/bin/restic` so it never fetches its own
binary. Alternative (packaging a module upstream) is out of scope.

### Nebula bind, not public

Bind the nebula IP exactly like linny-mcp (`listenAddress = "192.168.100.2"`); reach
it at `http://dapperehaan:9898` over the mesh. Rejected public durer-nginx exposure:
Backrest can `restore`/`forget`/`prune`, so the smallest attack surface wins, and
mesh reach is enough for a personal admin tool. Login auth is still enabled as
defence in depth.

### Declarative repo config from an aggregated dataset registry

The repo list already exists in Nix as each host's
`mipnix.backup.piethein.datasets`, but scattered per-host. Expose an aggregated
flake-level registry (same shape as the `flake.deploy` / nebula-nodes merge pattern)
mapping `<host>-<dataset>` → repo path. A generator turns that registry into
Backrest's `config.json` (repos only, all using the shared password/key). This keeps
a single source of truth and avoids click-ops; the alternative (add each repo by hand
in the UI) was rejected as imperative drift.

Because all repos share one password and one key, every generated repo entry
references the same `restic-repo-pw` and the same `restic-ssh-key` — no per-repo
credential handling.

### Viewer/restore only — no plans

Register repositories with **no backup plans**. Backrest can browse and restore from
a repo without a plan; omitting plans guarantees it never schedules a backup that
would race the NixOS timers. This is the key safety property of running a second
restic front-end against live repos.

### Credentials via agenix, dapperehaan as a recipient

dapperehaan is added to the `restic-ssh-key.age` and `restic-repo-pw.age` recipient
lists (then `rekey`), so the service user can read the SFTP key and repo password.
Backrest's own login credential is a new `backrest-auth` secret — never a literal in
a Nix option or baked into the store-resident config. Pin piethein's host key for the
service user (reuse the known-hosts value from `restic-piethein.nix`).

### SFTP is direct (no relay)

Since dapperehaan shares piethein's LAN, the restic SFTP command is
`ssh -i <key> -o StrictHostKeyChecking=yes resticbackup@192.168.2.100 -s sftp` with
no `ProxyCommand` — simpler than durer's relayed path.

## Risks / Trade-offs

- **Two restic front-ends on live repos** → Mitigated by no Backrest plans; it only
  reads and restores. A restore writes to a chosen target path, never into a repo.
- **Destructive actions exist in the UI** (`forget`/`prune`) → Mitigated by
  nebula-only reach + mandatory login; documented as operator-only.
- **Generated config in the store is world-readable** → It carries repo URLs and the
  *paths* to secrets, never secret values; the password/key/login stay in agenix
  files read at runtime.
- **Backrest config schema may change between versions** → Generator targets the
  pinned `pkgs.backrest` version; regenerate on bump. Verified by a start-up smoke
  test in tasks.
- **Registry aggregation forces evaluating other hosts' backup config** → Only the
  small `datasets` attrsets are read (literals), not full system configs, avoiding
  the `inputs.self` recursion seen with heavier derivations.

## Migration Plan

1. Add the aggregated dataset registry to the backup module.
2. Add `dapperehaan` to the two restic secrets' recipients; add `backrest-auth`
   secret; `./RUNME.sh rekey`.
3. Add the Backrest module on dapperehaan (unit, user, nebula bind, generated
   config, pinned restic, host-key pin).
4. Deploy dapperehaan; log in over nebula, confirm all repos list and a test restore
   works. Rollback is a revert + `rekey` — no NAS or backup-timer state changes.

## Resolved from source (backrest 1.14.1)

Verified against the pinned `pkgs.backrest` source (`proto/v1/config.proto`,
`internal/config/jsonstore.go`, `internal/config/migrations/*`,
`internal/env/environment.go`, `internal/auth`):

- **Config schema** (`Config`): `{ version, instance, repos[], plans[], auth }`.
  - `Repo`: `{ id, uri, env[], flags[], password, ... }` — set `env` to
    `[ "RESTIC_PASSWORD_FILE=<restic-repo-pw path>" ]` (keeps the secret value out of
    the config file) and leave `password` empty; `flags` carries the SFTP command.
  - `Auth`: `{ disabled, users[] }`; `User.passwordBcrypt` = **base64(bcrypt(pw))**.
- **`version` MUST be `6`** (`CurrentVersion = len(migrations)`); a fresh
  version-6 config skips all migrations.
- **Each repo MUST set `autoInitialize = true`** (or carry a 64-char `guid`) —
  `validateRepo` (validate.go) rejects a repo with neither and backrest exits 1 on
  startup. These repos already exist, so `autoInitialize` just lets backrest connect
  and derive the guid itself; it only creates a repo that is genuinely not found.
- **Env vars**: `BACKREST_CONFIG` (file), `BACKREST_DATA` (dir),
  `BACKREST_PORT` (full bind address — set `192.168.100.2:9898`),
  `BACKREST_RESTIC_COMMAND` (restic path). Default bind is `127.0.0.1:9898`, so the
  nebula bind is explicit and safe.
- **The config file is owned/rewritten by backrest** (`jsonstore.update` writes +
  `chmod 0600` + `.bak` rotation; migration006 persists an identity). It therefore
  cannot be a read-only store path — see the seed-once decision below.

### Decision: SFTP via restic `sftp.args` (quoted), not `sftp.command`

Getting the SSH key + host-key policy to restic took three tries against backrest's
behaviour (all confirmed in its source):
1. Inline `sftp.command=ssh -i key …` fails — backrest `shlex.Split`s each flag, so
   `-i` leaked as a top-level restic flag (`unknown shorthand flag: 'i'`).
2. A single-token `sftp.command=<wrapper script>` fixed that, but backrest
   auto-injects `-o sftp.args=-oBatchMode=yes` for sftp repos, and restic is fatal
   when both `sftp.command` and `sftp.args` are set ("cannot specify both").
3. Final: supply `-o sftp.args="-i <key> -oStrictHostKeyChecking=yes -oBatchMode=yes"`.
   The value is double-quoted so `shlex.Split` keeps it as one token; restic then
   re-splits it into ssh args. Because the flag contains the substring "sftp.args",
   backrest skips its own injection (repo.go), so there is no conflict. restic's
   `ssh` comes from the unit `path`.

`autoInitialize = true` is correct for these pre-existing repos: backrest's `init`
calls `Exists()` first and returns without running `restic init` when the repo is
found (restic.go), so it only ever connects and derives the guid.

### Decision: stamped re-seed (not strict seed-once)

The seed writes config.json when it is missing **or** when the Nix-generated
template's store path differs from a recorded stamp. Between deploys with an
unchanged template, backrest owns the file (runtime writes persist); a template
change (new repo, changed flags) re-seeds and backrest re-derives runtime bits.
This keeps the declarative intent without clobbering runtime state every boot, and
avoids a manual `rm config.json` on each config change.

### Watch-item: restic version

backrest 1.14.1 warns that the pinned restic 0.18.1 is below its preferred 0.19.1.
Non-fatal so far; if browse/restore hits an unsupported flag, pin a newer restic
(e.g. from `pkgs-unstable`) via `BACKREST_RESTIC_COMMAND`.

### Decision: seed-once config, not point-at-store

Because backrest must own a writable `config.json`, the Nix-generated config is
**seeded into the writable state dir on first start if absent** (an `ExecStartPre`
bootstrap, like linny-mcp's `secondbrain-clone`), after which backrest owns it. This
still delivers the declarative goal — a fresh deploy comes up with every repo
registered and auth set, zero clicks — but it is *bootstrap*, not *reconcile*:
adding a dataset later means re-seeding (stop, remove `config.json`, start) or adding
the repo in the UI. Overwriting the file every boot was rejected because it would
clobber backrest's own writes (lazy `guid`, identity, any UI edit).

### Decision: aggregate datasets by per-host flake contribution

Each backup host hoists its `datasets` into a shared `let` binding used both for
`mipnix.backup.piethein.datasets` and a flake-level `flake.resticRepos.<host>`
contribution (mergeable option, like `deploy-option.nix`). dapperehaan's generator
reads `self.resticRepos` — plain data, so no full-system eval and no `inputs.self`
recursion. The repo URI is derived (`…/ResticBackups/<name>`), so names are not
restated.

## Open Questions

- Backrest data dir growth (restore staging/caches): confirm it lives under the
  service `StateDirectory` and needs no extra retention handling.
