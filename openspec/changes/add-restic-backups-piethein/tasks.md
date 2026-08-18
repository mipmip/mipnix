## 1. NAS precondition (manual, one-time on piethein)

- [ ] 1.1 Confirm DSM SFTP file-service is enabled and `resticbackup` has R/W on the `ResticBackups` share (already validated; re-confirm)
- [ ] 1.2 Confirm `resticbackup` is **not** in the `administrators` group
- [ ] 1.3 Generate a dedicated ed25519 backup keypair (offline / on a trusted machine)
- [ ] 1.4 Append the backup **public** key to `resticbackup`'s `authorized_keys` on piethein (optionally with `restrict,from="<LAN/nebula CIDRs>"`)

## 2. Secrets (agenix)

- [ ] 2.1 Add `restic-ssh-key.age` to `secrets/secrets.nix` with recipients `[ pim cichorei hurry durer ]`
- [ ] 2.2 Add `restic-repo-pw.age` to `secrets/secrets.nix` with recipients `[ pim cichorei hurry durer ]`
- [ ] 2.3 Encrypt the backup **private** key into `secrets/restic-ssh-key.age`
- [ ] 2.4 Generate a strong repo password and encrypt it into `secrets/restic-repo-pw.age`
- [ ] 2.5 Store the backup private key **and** repo password in an offline/independent location (password manager / paper)
- [ ] 2.6 Remove or repurpose the abandoned `secrets/ssh-password-resticbackup.age` and its `secrets.nix` entry

## 3. Reusable role module

- [ ] 3.1 Create `modules/services/backup/restic-piethein.nix` defining `flake.modules.nixos.backup-restic-piethein`
- [ ] 3.2 Define an option for the per-host target list: `{ path? | prepareCmd?/cleanupCmd?, repo, keepArgs, tag? }`
- [ ] 3.3 Map each target to `services.restic.backups.<repo>` with `repository = "sftp:resticbackup@192.168.2.100:/ResticBackups/${repo}"`
- [ ] 3.4 Wire `passwordFile` to the `restic-repo-pw` agenix secret
- [ ] 3.5 Wire SFTP transport to the `restic-ssh-key` agenix secret via `extraOptions` `sftp.command` (`ssh -i <key> … -s sftp`) with strict host-key checking
- [ ] 3.6 Pin piethein's host key via `programs.ssh.knownHosts`
- [ ] 3.7 Set `timerConfig` (`OnCalendar = "hourly"`, `Persistent = true`, `RandomizedDelaySec`) and network-online ordering
- [ ] 3.8 Set `pruneOpts` from each target's `keepArgs` so `forget --prune` runs after backup
- [ ] 3.9 Support `backupPrepareCommand`/`backupCleanupCommand` for DB-dump targets

## 4. Enable on cichorei

- [ ] 4.1 Import the role in `modules/HOSTS/cichorei-laptop/configuration.nix` and declare the agenix secrets on the host
- [ ] 4.2 Add targets: `.claude` (h24 d7), `secondbrain` (h24 d7 w5 m12 y9999), `.ssh` (h24 d7)
- [ ] 4.3 Deploy; verify first backup auto-inits each repo; run `restic snapshots` + `restic check`

## 5. Enable on hurry

- [ ] 5.1 Import the role in `modules/HOSTS/hurry-pi/configuration.nix` and declare the agenix secrets on the host
- [ ] 5.2 Add targets: `/var/lib/backups/vaultwarden` (h24 d14 m6), `.ssh` (h24 d7)
- [ ] 5.3 Deploy; verify snapshots + check

## 6. Enable on durer (with DB dumps)

- [ ] 6.1 Import the role in `modules/HOSTS/durer-server/configuration.nix` and declare the agenix secrets on the host
- [ ] 6.2 voorzetramenshop target: `backupPrepareCommand` = `sudo -u postgres pg_dump voorzetramenshop > <dump>`, back up the dump, cleanup after (h24 d14 m6)
- [ ] 6.3 umami target: `backupPrepareCommand` = `docker exec umami-db pg_dump -U <user> <db> > <dump>` (creds from `umami-env`), back up the dump, cleanup after (h24 d7)
- [ ] 6.4 `.ssh` target (h24 d7)
- [ ] 6.5 Deploy; verify dump files are produced, snapshots exist, dumps are cleaned up, and `restic check` passes

## 7. Verification & retention

- [ ] 7.1 Confirm timers are hourly/persistent and staggered across hosts (`systemctl list-timers`)
- [ ] 7.2 Do a test restore of at least one file from one repo per host (e.g. `restic restore`) to prove recoverability
- [ ] 7.3 Confirm `forget --prune` reduces snapshots per the configured `--keep-*` policy (including secondbrain's yearly-forever)
- [ ] 7.4 Document the restore procedure (repo path, key, offline password) briefly for future-you
