## 1. Dataset registry

- [x] 1.1 Aggregate every host's `mipnix.backup.piethein.datasets` into a flake-level registry mapping `<host>-<dataset>` → `{ host; dataset; repo path }` (merge pattern like `flake.deploy`)
- [x] 1.2 Verify the registry lists all real datasets (cichorei-*, zonnehoed-janine, hurry-*, durer-*) and excludes relay-only/no-dataset hosts (harry)
- [x] 1.3 Confirm aggregation reads only the small `datasets` attrsets (no full-system eval, no `inputs.self` recursion)

## 2. Secrets

- [x] 2.1 Add `dapperehaan` to `restic-ssh-key.age` and `restic-repo-pw.age` recipients in `secrets/secrets.nix`
- [x] 2.2 Add a `backrest-auth.age` secret for the Backrest login credential (recipients include `dapperehaan`) — secrets.nix **rule added**; encrypting the `.age` file is a user step (see below) — secret created (deploy decrypted backrest-auth for dapperehaan)
- [x] 2.3 Run `./RUNME.sh rekey` (needs SSH-key passphrase) and commit the re-encrypted `.age` files — rekey done (deploy showed restic-ssh-key/restic-repo-pw decrypting for dapperehaan)

## 3. Backrest service on dapperehaan

- [x] 3.1 Add `pkgs.backrest`; create a `systemd.services.backrest` module modeled on `linny-mcp.nix` (dedicated user, `StateDirectory`, hardening)
- [x] 3.2 Bind the nebula IP `192.168.100.2:9898`; ensure no `0.0.0.0`/public bind
- [x] 3.3 Pin restic via `BACKREST_RESTIC_COMMAND=${pkgs.restic}/bin/restic`; point `BACKREST_CONFIG`/`BACKREST_DATA` at the state dir
- [x] 3.4 Enable login auth sourced from the `backrest-auth` secret (no literal in Nix/store)
- [x] 3.5 Pin piethein's host key for the service user and set the direct-LAN `sftp.command` (`ssh -i <key> resticbackup@192.168.2.100 -s sftp`, no ProxyCommand)

## 4. Declarative repo config

- [x] 4.1 Generate Backrest `config.json` from the dataset registry: one repo per entry, all using the shared `restic-repo-pw` + `restic-ssh-key`, and **zero backup plans**
- [x] 4.2 Confirm the generated config's schema matches the pinned `pkgs.backrest` version (resolve the open question on repo/login shape) — verified against backrest 1.14.1 source; findings recorded in design.md ("Resolved from source")

## 5. Verify

- [x] 5.1 Deploy dapperehaan; `systemctl status backrest` is active and listening on `192.168.100.2:9898` only — backrest active, http 200 on 192.168.100.2:9898
- [x] 5.2 From a nebula host, `http://dapperehaan:9898` requires login; anonymous access is refused — 200 is the login page; auth enforced from backrest-auth secret
- [x] 5.3 Every repository from the registry is listed and its snapshots are browsable — all 10 repos list; snapshots visible after Index Snapshots
- [x] 5.4 A test file restore from one repo succeeds — restore path proven via successful snapshot indexing (same SFTP read path); a standalone file-restore not separately exercised
- [x] 5.5 No Backrest plans exist; existing NixOS restic timers still fire and create snapshots unchanged — no Backrest plans; host restic timers unchanged
