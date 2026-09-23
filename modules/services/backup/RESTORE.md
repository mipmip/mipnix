# Restoring from the piethein restic backups

Backups are made by `modules/services/backup/restic-piethein.nix` to the Synology
NAS **piethein** over SFTP. One restic repository per (host, dataset) lives under
`/ResticBackups/<host>-<dataset>` (e.g. `cichorei-secondbrain`, `hurry-vaultwarden`,
`durer-voorzetramenshop`).

## What you need

1. **The repo password** — agenix `secrets/restic-repo-pw.age`. Also kept OFFLINE
   (password manager). A dead host cannot decrypt its own agenix secrets, so the
   offline copy is what you use in a bare-metal restore.
2. **The backup SSH key** — agenix `secrets/restic-ssh-key.age` (offline copy too).
   Its public half is in `resticbackup`'s `authorized_keys` on piethein.

On a running backup host both are already at `/run/agenix/restic-repo-pw` and
`/run/agenix/restic-ssh-key` (root-readable).

## Restore (from a LAN host — cichorei/hurry)

```sh
export RESTIC_PASSWORD="$(cat /path/to/repo-password)"
export RESTIC_REPOSITORY="sftp:resticbackup@192.168.2.100:/ResticBackups/<host>-<dataset>"
RCMD="ssh -i /path/to/restic-ssh-key -o BatchMode=yes resticbackup@192.168.2.100 -s sftp"

restic -o sftp.command="$RCMD" snapshots                    # list snapshots
restic -o sftp.command="$RCMD" restore latest --target /tmp/restore
```

## Restore (from a cloud host — durer, no LAN route)

durer reaches piethein only through a relay Pi over nebula. Route the sftp command
through the relay (hurry primary, harry failover):

```sh
RCMD="ssh -i /path/to/restic-ssh-key \
  -o ProxyCommand='ssh -i /path/to/restic-ssh-key -W 192.168.2.100:22 restic-relay@192.168.100.6' \
  resticbackup@192.168.2.100 -s sftp"
```

(Swap `192.168.100.6` → `.7` to use harry.)

## Notes

- Repos are encrypted at rest; without the repo password the data is unrecoverable.
- `restic-relay` on the Pis can only forward to `192.168.2.100:22` — no shell, no
  other destinations.
- Databases are stored as `pg_dump` output (`<host>-voorzetramenshop`, `<host>-umami`);
  restore the `.sql` file, then `psql`/`pg_restore` it into the target DB.
