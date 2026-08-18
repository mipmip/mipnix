## Context

piethein is a Synology DSM NAS (192.168.2.100) that is **not** managed by this Nix
repo. It already has a `resticbackup` user, a `/volume1/ResticBackups` shared folder,
and DSM's SFTP file-service enabled. This repo is flake-parts with `import-tree` over
`./modules`; NixOS services live under `modules/services/` as
`flake.modules.nixos.<name>` and are imported per host from
`modules/HOSTS/<host>/configuration.nix`. Secrets use agenix, with recipients declared
in `secrets/secrets.nix` keyed by host/user public keys.

The transport approach was validated by hand before writing this design (init / backup /
snapshots / check all succeeded) — see Decisions for what the tests established.

## Goals / Non-Goals

**Goals:**
- Hourly, encrypted, unattended restic backups of irreplaceable data from cichorei,
  hurry, and durer to piethein.
- Minimal, one-time NAS-side change (a single `authorized_keys` line).
- A single reusable role so adding a host/dataset is a few declarative lines.
- Per-dataset retention, including "keep forever" for `secondbrain`.
- Consistent database snapshots (dump-to-file) rather than copying live DB files.

**Non-Goals:**
- Ransomware/delete-resistance (append-only) — future enhancement.
- Offsite/second-copy (3-2-1) — future enhancement.
- Converting the NAS volume to Btrfs for snapshotting — destructive, rejected.
- Backing up dapperehaan, harry/nextcloud, or dirty git working copies.

## Decisions

### D1: SFTP as non-admin `resticbackup` via DSM's SFTP file-service
DSM blocks shell/exec sessions for non-admin users (PAM), but its **SFTP file-service
authorizes SFTP independently** — verified: a non-admin `resticbackup` completed a full
`restic init/backup/check`, while `ssh … <shell command>` was still denied. restic only
needs the SFTP subsystem, so the account stays non-admin.
- *Alternative rejected*: adding `resticbackup` to `administrators` (works, but grants
  DSM admin if the key leaks). Not needed.
- *Alternative rejected*: restic rest-server (better, append-only) — more NAS work; deferred.

### D2: Chrooted repository path `/ResticBackups/<host>-<dataset>`
The SFTP service chroots the user, so the share is reached at `/ResticBackups`, **not**
`/volume1/ResticBackups` (confirmed by `pwd` = `/` with shares at the root). Repos are
named `<host>-<dataset>` — one repo per dataset (Option A), so retention is a simple
per-repo policy and datasets never share an encryption scope or a lock.

### D3: One shared dedicated ed25519 keypair + one shared repo password
A single backup keypair (not pim's personal key) is distributed to the backup hosts via
agenix `restic-ssh-key.age`; its public half is the one line added to piethein's
`authorized_keys`. A single `restic-repo-pw.age` encrypts all repos.
- *Rationale*: single-admin home fleet; per-host keys/passwords add secret sprawl for
  little isolation benefit.
- *Consequence*: both secrets must also live **offline** (D5).

### D4: Reusable role module with a per-host target list
`modules/services/backup/restic-piethein.nix` defines
`flake.modules.nixos.backup-restic-piethein`, which maps a per-host list of
`{ path | prepareCmd, repo, keepArgs, tag }` onto `services.restic.backups.<repo>` with:
- `repository = "sftp:resticbackup@192.168.2.100:/ResticBackups/${repo}"`
- `passwordFile = age restic-repo-pw`
- `extraOptions = [ "sftp.command='ssh -i <key> -o … resticbackup@192.168.2.100 -s sftp'" ]`
- `timerConfig = { OnCalendar = "hourly"; Persistent = true; RandomizedDelaySec = …; }`
- `pruneOpts = keepArgs`, `backupPrepareCommand`/`backupCleanupCommand` for DB dumps.
Hosts import the module and set their list; the module owns all the boilerplate.

### D5: Host key pinning + offline restore credentials
piethein's host key is pinned via `programs.ssh.knownHosts` (systemd is non-interactive
and cannot `accept-new`). The repo password and backup key are additionally stored in an
independent location (password manager / paper) so a destroyed host can be restored —
its own agenix secrets are undecryptable once its host key is gone.

### D6: Database dumps via NixOS restic hooks
`backupPrepareCommand` writes a dump to a scratch file; restic backs up the file;
`backupCleanupCommand` removes it.
- voorzetramenshop: native PostgreSQL, peer auth → `sudo -u postgres pg_dump voorzetramenshop`.
- umami: PostgreSQL 14 in Docker → `docker exec umami-db pg_dump -U <user> <db>` (creds from `umami-env`).

### D7: durer (cloud) reaches piethein via a nebula relay Pi, with failover

durer is a Hetzner cloud host with no route to piethein's LAN address
(`192.168.2.100`), and piethein is not on nebula. Rather than expose piethein to
the internet or put it on nebula (Synology work we're avoiding), durer tunnels
through a relay Pi that is on both nebula and the LAN. restic's `sftp.command`
uses a generated `ProxyCommand` script that tries each relay in order
(`ssh -W piethein:22 restic-relay@<nebula-ip>`), giving **hurry primary, harry
failover**. Relay hosts set `relay = true`, which creates a locked-down
`restic-relay` system user (`nologin`, key option
`restrict,port-forwarding,permitopen="192.168.2.100:22"`) — it can *only* forward
to piethein, nothing else. The relay never sees plaintext (restic encrypts
end-to-end) and relay-only hosts need no backup secrets (not agenix recipients).
- *Alternatives rejected*: expose piethein SFTP publicly (attack surface); put
  piethein on nebula (ongoing Synology upkeep); durer → cloud store (new
  target/cost — reasonable future option but out of scope here).
- *Deploy order*: relays (hurry, harry) before durer, so the `restic-relay` user
  exists when durer first connects.

## Risks / Trade-offs

- **A compromised backup host can delete/overwrite repos on piethein** (SFTP allows
  writes; no append-only). → Accept for v1; mitigate later with rest-server `--append-only`
  or an offsite `restic copy`. Restrict the key with `restrict,from="<LAN/nebula>"` in
  `authorized_keys`.
- **Single shared repo password**: losing it loses every repo. → Offline copy (D5);
  `restic check` on a schedule.
- **cichorei is a laptop** (sleeps/roams): "hourly" is best-effort. → `Persistent` timer
  absorbs missed windows; not treated as a failure.
- **DSM upgrades could reset SFTP/sshd config**. → Documented as a manual NAS
  precondition; backups will fail loudly (monitored) rather than silently.
- **DB dump correctness** (schema/creds drift). → Dump command is asserted to exit 0;
  a failed dump fails the backup rather than storing a stale/empty file.
- **`.ssh` contains private keys** → fine: repos are encrypted at rest, and this is
  exactly the material you need after a disk loss.

## Migration Plan

1. Generate the dedicated ed25519 backup keypair; add its public key to
   `resticbackup`'s `authorized_keys` on piethein (only NAS-side step).
2. Add `restic-ssh-key.age` and `restic-repo-pw.age` to `secrets/secrets.nix`
   (recipients: cichorei, hurry, durer, pim); create the encrypted files; store both
   secrets offline. Remove/repurpose `ssh-password-resticbackup.age`.
3. Add the role module; enable it on cichorei first (fastest to iterate), then hurry,
   then durer (with DB dump hooks).
4. For each repo, the first `restic backup` auto-inits it; verify with `restic snapshots`
   and `restic check`.
5. Rollback: disabling the module removes the timers/services; existing repos on piethein
   are untouched and can be deleted manually if abandoning.

## Open Questions

- Exact `RandomizedDelaySec` / stagger between hosts (cosmetic; pick a sane default like
  `30m`).
- Whether to also add `restrict,from="…"` to the NAS key now or defer with the other
  hardening. (Leaning: add `from=` now — it's free.)
