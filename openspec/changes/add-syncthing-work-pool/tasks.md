> Work the sections in order. Sections 1 and 2 produce the identities everything
> else depends on, and section 3 cannot be written until the device IDs exist.
>
> **Deployment order matters.** dapperehaan is the hub and must be a working
> member before either laptop joins, so that the first thing a laptop syncs with
> is a host that retains deletions. Section 6 lands dapperehaan alone; section 7
> adds the laptops.
>
> Sections 8 and 9 are acts across several running machines that no single tool
> can perform. The change is NOT archived until they pass.

## 1. Generate the three device identities

> A device ID is a hash of the device's TLS certificate, so the certificate has
> to exist before the ID can be written anywhere. Generate all three off-host, in
> one sitting, then never touch them again.

- [x] 1.1 For each of cichorei, doornappel and dapperehaan, generate a
      certificate and key pair into a scratch directory:
      `syncthing generate --home=<scratch>/<host>`.
- [x] 1.2 Read each device ID: `syncthing --home=<scratch>/<host> --device-id`.
      Record the three IDs; they are the registry contents in task 3.2.
- [x] 1.3 Confirm the three IDs differ from each other. An identical pair means
      a scratch directory was reused and the generation must be redone.

## 2. Commit the identities to agenix

- [x] 2.1 In `secrets/secrets.nix`, add recipients for the six new secrets,
      following the `nebula-<host>.{crt,key}.age` entries at lines 133, 152 and
      166. Each host needs its own pair; use the same `users ++ systems` breadth
      the nebula certificates use unless there is a reason to narrow it.
- [x] 2.2 Encrypt each pair as `secrets/syncthing-<host>.crt.age` and
      `secrets/syncthing-<host>.key.age`.
- [x] 2.3 Destroy the scratch directory from section 1. The private keys now live
      only in agenix.
- [x] 2.4 Confirm each secret decrypts for its intended host.

## 3. The registry

- [x] 3.1 Create `modules/services/sync/syncthing-devices-option.nix` declaring
      `flake.syncthingDevices` as an attrset of host name to device ID. Model it
      on `modules/services/networking/nebula-nodes-option.nix`, including the
      comment explaining that it carries plain strings so consumers can read it
      without forcing `nixosConfigurations`.
- [x] 3.2 Have each member host contribute its own line, the way each host
      contributes `flake.nebulaNodes.<host>` from its own `networking.nix`. Do
      not centralise the three IDs in one file: the point of the registry is that
      a host declares itself.
- [x] 3.3 `nix eval .#syncthingDevices` returns the three entries.

## 4. The pool module

- [x] 4.1 Create `modules/services/sync/syncthing-pool.nix` defining
      `flake.modules.nixos.syncthing-work-pool` with options
      `mipnix.syncthing.pool.enable` and `mipnix.syncthing.pool.hub`. Header
      comment records why the peer list comes from the registry rather than from
      other hosts' configuration: reading peers from evaluated configs is a cycle
      as soon as two members exist.
- [x] 4.2 Derive peers as the registry minus `config.networking.hostName`. Each
      peer gets `id` from the registry and
      `addresses = [ "tcp://<name>:22000" ]`, using the mesh hostname rather than
      the IP, because `networking-nebula` already writes every node into
      `networking.extraHosts` from `flake.nebulaNodes`.
- [x] 4.3 Wire identity: `services.syncthing.cert` and `.key` to the agenix
      paths for this host. Confirm the syncthing service user can read them.
- [x] 4.4 Run as `pim` with the folder at `/home/pim/Work`. The module default
      `dataDir` is `/var/lib/syncthing`, so set it explicitly.
- [x] 4.5 Turn off outside discovery: `globalAnnounceEnabled`,
      `localAnnounceEnabled` and `relaysEnabled` all false.
- [x] 4.6 Define the folder with a stable id and the shared `ignorePatterns`
      list: at minimum `node_modules`, `.venv`, `target`, `.direnv`, `result`.
      Comment that `overrideFolders` defaults true, so a pattern added in the web
      UI is reverted on restart, which is intended.
- [x] 4.7 Under `hub = true`, set the folder `type = "receiveonly"` and configure
      staggered versioning. Comment the distinction: `receiveonly` stops local
      edits propagating outward, versioning is what covers deletions arriving
      from a laptop. They are not substitutes.
- [x] 4.8 Leave the GUI on its default `127.0.0.1:8384`. Exposing it on the mesh
      is a separate decision, not a side effect of this change.

## 5. Static checks before anything is deployed

- [x] 5.1 Build `nixosConfigurations.dapperehaan`, `.cichorei` and `.doornappel`.
      Note that this repo needs `--impure`: `pim-awscli-dir` reads
      `~/.aws/other_accounts.json`, which pure evaluation forbids.
- [x] 5.2 Confirm each built configuration lists exactly the other two members as
      peers, and not itself.
- [x] 5.3 Confirm no member's nebula IP appears as a literal in the generated
      syncthing configuration.
- [x] 5.4 `git add` any new files before building. A flake build only sees
      tracked files, so an untracked module is silently omitted rather than
      erroring.

## 6. Deploy the hub first

- [x] 6.1 Add `syncthing-work-pool` to dapperehaan's imports, set
      `mipnix.syncthing.pool = { enable = true; hub = true; }`, and add its
      registry line.
- [x] 6.2 Add `backup-restic-piethein` to dapperehaan's imports and set
      `mipnix.backup.piethein = { enable = true; datasets.dapperehaan-work = { paths = [ "/home/pim/Work" ]; keep = <long-retention profile>; }; }`.
      Use the same keep list secondbrain and documents use.
- [x] 6.3 Add `flake.resticRepos.dapperehaan = builtins.attrNames datasets;`
      following the pattern in every other backup host.
- [x] 6.4 Check for a secrets collision: `backrest.nix:99` already declares
      `age.secrets.restic-ssh-key` and `restic-repo-pw`, and
      `backup-restic-piethein` declares the same two. Identical values merge;
      differing paths do not. Resolve if they differ.
- [x] 6.5 Deploy dapperehaan. Confirm the syncthing service is running as `pim`,
      `/home/pim/Work` exists, and the device ID it reports matches the registry.
- [x] 6.6 Confirm the restic timer exists and its first run succeeds against an
      empty folder.
- [x] 6.7 Confirm `dapperehaan-work` now appears in the Backrest console's
      repository list.

## 7. Add the laptops

- [ ] 7.1 Add the module, `mipnix.syncthing.pool.enable = true` and the registry
      line to cichorei. Deploy.
- [ ] 7.2 Confirm cichorei connects to dapperehaan, and that the connection is
      over the mesh rather than the LAN.
- [ ] 7.3 Repeat for doornappel. Deploy.
- [ ] 7.4 Confirm all three are mutually connected, and that no member needed an
      approval click anywhere.

## 8. Verify the pool by hand

- [ ] 8.1 Create a file in `~/Work` on cichorei. Confirm it appears on doornappel
      and on dapperehaan.
- [ ] 8.2 Modify it on doornappel. Confirm the change reaches the other two.
- [ ] 8.3 Create `~/Work/scratch/node_modules/` with a file inside on cichorei.
      Confirm it does NOT appear on the other two.
- [ ] 8.4 Stop syncthing on dapperehaan. Confirm cichorei and doornappel still
      sync with each other. Start it again and confirm it converges. This is the
      degraded case the LUKS-at-boot risk produces, so record how long
      convergence takes.
- [ ] 8.5 Edit the same file on cichorei and doornappel while both are cut off
      from each other, then reconnect. Confirm both versions survive and one
      carries a conflict name.
- [ ] 8.6 Take cichorei off the network, change files elsewhere, bring it back.
      Confirm it converges.

## 9. Verify the safety properties

> These are the reason the hub is configured the way it is. Test them
> deliberately rather than trusting the options.

- [ ] 9.1 Edit a file directly on dapperehaan. Confirm the edit does NOT
      propagate to either laptop. That is `receiveonly` working.
- [ ] 9.2 Delete a file on cichorei. Confirm it disappears on doornappel and on
      dapperehaan, AND that the previous contents are retained under
      dapperehaan's versioning directory. That is the hour-long window being
      closed.
- [ ] 9.3 Overwrite a file on cichorei with different contents. Confirm the
      previous version is retained on dapperehaan.
- [ ] 9.4 Wait for a restic run, then delete a file across the pool. Confirm the
      file is still present in the last snapshot and recoverable through
      Backrest.
- [ ] 9.5 Write into `~/Work` on dapperehaan over the Samba share
      (`services-samba` shares `/home/pim`). Confirm the write does not propagate,
      and that a delete over SMB leaves a retained version.
- [ ] 9.6 Add a peer through dapperehaan's web UI, restart the service, and
      confirm the peer is gone. That is `overrideDevices` working.

## 10. Close out

- [x] 10.1 Update `modules/programs/desktop/utils/filesync.nix`: its commented-out
      `syncthing` package line now reads as the plan when it is not. Either
      remove it or point it at the module.
- [ ] 10.2 `openspec validate add-syncthing-work-pool --strict`.
- [ ] 10.3 Record in `secrets/RESTORE.md`, or alongside it, how to restore
      `dapperehaan-work` and what the versioning directory on the hub is for. A
      restore path nobody has written down is not a restore path.
