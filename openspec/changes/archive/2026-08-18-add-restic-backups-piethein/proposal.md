## Why

Several hosts hold data that exists nowhere else — pim's `secondbrain` notes, the
vaultwarden password vault, the voorzetramenshop webshop database, umami analytics,
and per-host SSH keys — yet none of it is backed up. There is already a Synology NAS
("piethein", 192.168.2.100) with a `resticbackup` user and a `/ResticBackups` share,
so we can start protecting this data now with almost no work on the (non-Nix-managed)
NAS.

## What Changes

- Add a reusable NixOS backup role that runs hourly `restic` backups over SFTP to
  piethein, enabled per host with a declarative list of `{ path, repo, retention,
  prepareCmd? }` entries.
- Authenticate as the **non-admin** `resticbackup` user via DSM's SFTP file-service
  (validated: it authorizes SFTP independently of DSM's shell restriction). Repos live
  at the chrooted path `sftp:…:/ResticBackups/<host>-<dataset>` — **one repo per
  (host, dataset)**.
- Introduce **one shared dedicated ed25519 keypair** (transport) and **one shared
  restic repository password** (encryption), both stored via agenix. The only change
  on the Synology is adding one public-key line to `resticbackup`'s `authorized_keys`.
- Back up, hourly with per-dataset retention:
  - cichorei: `/home/pim/.claude`, `/home/pim/secondbrain` (**kept forever**), `/home/pim/.ssh`
  - hurry: `/var/lib/backups/vaultwarden` (existing consistent sqlite snapshot), `/home/pim/.ssh`
  - durer: voorzetramenshop PostgreSQL (via `pg_dump` prepare step), umami PostgreSQL
    (via `docker exec … pg_dump`), `/home/pim/.ssh`
- Pin piethein's SSH host key (`programs.ssh.knownHosts`) so unattended systemd runs
  don't need interactive host-key acceptance.
- Remove/repurpose the abandoned password-auth secret `secrets/ssh-password-resticbackup.age`.

Explicitly **out of scope**: dapperehaan (openclaw/matrix), harry/nextcloud, backing up
"dirty" git working copies, and any Btrfs conversion of the NAS volume (destructive; no
in-place conversion on Synology). Ransomware/delete-resistance (append-only rest-server
or offsite `restic copy`) is noted as a future enhancement.

## Capabilities

### New Capabilities
- `host-backups`: Declarative, per-host restic backups to the piethein NAS — repository
  layout and naming, SFTP transport via the shared backup key, encryption via the shared
  repo password, hourly scheduling with per-dataset retention/pruning, database dump
  hooks for consistent snapshots, and unattended (non-interactive) operation.

### Modified Capabilities
<!-- None: no existing spec's requirements change. -->

## Impact

- **New module**: `modules/services/backup/restic-piethein.nix` (flake-parts
  `flake.modules.nixos.<name>`), imported per host.
- **Host configs**: `modules/HOSTS/{cichorei-laptop,hurry-pi,durer-server}/` enable the
  role with their target lists.
- **Secrets**: `secrets/secrets.nix` gains `restic-ssh-key.age` and `restic-repo-pw.age`
  (recipients: backup hosts + pim); `ssh-password-resticbackup.age` removed/repurposed.
  A copy of the repo password + backup key must be stored **offline** (restore-bootstrap).
- **Synology (piethein)**: one `authorized_keys` line for the new backup key; DSM SFTP
  file-service enabled (already done); `resticbackup` remains non-admin.
- **Dependencies**: `restic` (nixpkgs `services.restic`); `pg_dump`/`docker` already
  present on durer.
- **Data written to NAS**: encrypted restic repos under `/ResticBackups/`.
