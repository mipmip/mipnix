## 1. NAS precondition (manual, one-time on piethein)

- [x] 1.1 Confirm DSM SFTP file-service is enabled and `resticbackup` has R/W on the `ResticBackups` share (validated: restic init/backup/check succeeded)
- [x] 1.2 Confirm `resticbackup` is **not** in the `administrators` group (validated: works without admin)
- [x] 1.3 Generate a dedicated ed25519 backup keypair (done on cichorei; plaintext in scratchpad for offline copy)
- [x] 1.4 Append the backup **public** key to `resticbackup`'s `authorized_keys` on piethein (optionally with `restrict,from="<LAN/nebula CIDRs>"`)

## 2. Secrets (agenix)

- [x] 2.1 Add `restic-ssh-key.age` to `secrets/secrets.nix` with recipients `[ pim cichorei hurry durer ]`
- [x] 2.2 Add `restic-repo-pw.age` to `secrets/secrets.nix` with recipients `[ pim cichorei hurry durer ]`
- [x] 2.3 Encrypt the backup **private** key into `secrets/restic-ssh-key.age` (4 recipients)
- [x] 2.4 Generate a strong repo password and encrypt it into `secrets/restic-repo-pw.age` (4 recipients)
- [x] 2.5 Store the backup private key **and** repo password in an offline/independent location (password manager / paper)
- [x] 2.6 Remove the abandoned `secrets/ssh-password-resticbackup.age` and its `secrets.nix` entry

## 3. Reusable role module

- [x] 3.1 Create `modules/services/backup/restic-piethein.nix` defining `flake.modules.nixos.backup-restic-piethein`
- [x] 3.2 Define the per-host dataset option: `{ repo, paths, keep, prepareCommand?, cleanupCommand? }`
- [x] 3.3 Map each target to `services.restic.backups.<repo>` with `repository = "sftp:…:/ResticBackups/${repo}"`
- [x] 3.4 Wire `passwordFile` to the `restic-repo-pw` agenix secret
- [x] 3.5 Wire SFTP transport to the `restic-ssh-key` agenix secret via `extraOptions` `sftp.command` with strict host-key checking
- [x] 3.6 Pin piethein's host key via `programs.ssh.knownHosts`
- [x] 3.7 Set `timerConfig` (`OnCalendar = "hourly"`, `Persistent = true`, `RandomizedDelaySec = "30m"`) 
- [x] 3.8 Set `pruneOpts` from each target's `keep` so `forget --prune` runs after backup
- [x] 3.9 Support `backupPrepareCommand`/`backupCleanupCommand` for DB-dump targets

## 4. Enable on cichorei

- [x] 4.1 Import the role in `modules/HOSTS/cichorei-laptop/configuration.nix` (secrets declared by the module)
- [x] 4.2 Add targets: `.claude` (h24 d7), `secondbrain` (h24 d7 w5 m12 y9999), `.ssh` (h24 d7)
- [x] 4.3 Rebuild cichorei; verify first backup auto-inits each repo; `restic snapshots` + `restic check`

## 5. Enable on hurry

- [x] 5.1 Import the role in `modules/HOSTS/hurry-pi/configuration.nix` (secrets declared by the module)
- [x] 5.2 Add targets: `/var/lib/backups/vaultwarden` (h24 d14 m6), `.ssh` (h24 d7)
- [ ] 5.3 Deploy; verify snapshots + check

## 6. Enable on durer (with DB dumps)

- [x] 6.1 Import the role in `modules/HOSTS/durer-server/configuration.nix` (secrets declared by the module)
- [x] 6.2 voorzetramenshop target: `pg_dump` via `runuser -u postgres` to a dump file, back up, cleanup (h24 d14 m6)
- [x] 6.3 umami target: `docker exec umami-db … pg_dump` to a dump file, back up, cleanup (h24 d7)
- [x] 6.4 `.ssh` target (h24 d7)
- [ ] 6.5 Deploy; verify dumps are produced, snapshots exist, dumps are cleaned up, `restic check` passes

## 7. Verification & retention

- [ ] 7.1 Confirm timers are hourly/persistent and staggered across hosts (`systemctl list-timers`)
- [x] 7.2 Test-restore at least one file from one repo per host to prove recoverability
- [ ] 7.3 Confirm `forget --prune` reduces snapshots per policy (incl. secondbrain's yearly-forever)
- [ ] 7.4 Document the restore procedure (repo path, key, offline password) briefly
