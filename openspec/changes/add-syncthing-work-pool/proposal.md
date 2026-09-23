## Why

There is no `/home/pim/Work`, and no mechanism that would keep one in step across
machines. Getting a working file from one laptop to another today means git, a
USB stick, or a copy over SMB to dapperehaan. Nothing carries state between
machines that is not a git repository.

The current backup design makes this worse rather than better, in three ways
that a shared folder removes outright.

**1. Every laptop is its own backup client, and each one is hand-rolled.** Five
hosts declare a `datasets` block by hand. cichorei has four datasets, zonnehoed
one, hurry two, durer three. The retention lists are restated per dataset.
Adding a machine means writing the block again.

**2. doornappel looks backed up and is not.**
`modules/HOSTS/doornappel-laptop/configuration.nix:50` imports
`backup-restic-piethein` and never sets `mipnix.backup.piethein`. The module is
`mkIf cfg.enable`, so it evaluates to nothing. The import reads as protection at
a glance and provides none.

**3. Laptop backups only work at home.** `restic-piethein.nix` hardcodes
`host = "192.168.2.100"`, a LAN address, and `proxyJump` defaults to `[ ]`. Only
durer sets it. So every laptop's hourly restic timer fails whenever the machine
is away from the house, repeatedly, into the journal. The nebula machinery to
fix that exists and is proven on durer; no laptop uses it.

A Syncthing pool over the existing nebula mesh removes all three for the data it
covers. Laptops stop being backup clients and become sync peers. One always-on
machine holds the authoritative copy and is the only host that talks to the NAS.
Membership becomes a declared property of a host rather than a block of
per-host configuration that can be silently absent.

## What Changes

- **A Syncthing pool over nebula.** A new NixOS module gives a host
  `mipnix.syncthing.pool.enable`. An enabled host joins the pool, shares
  `/home/pim/Work` with every other member, and reaches them over the nebula
  mesh. Initial members: cichorei, doornappel and dapperehaan.

- **Device identity is declarative.** Each member's Syncthing TLS certificate and
  key are generated once, committed to agenix, and installed through
  `services.syncthing.cert` / `.key`. The resulting device IDs live in a new
  `flake.syncthingDevices` registry. This mirrors exactly how nebula certificates
  are already handled, and it means a freshly built host is a pool member on
  first boot with no console step.

- **Peers are derived, never restated.** A member's peer list is the registry
  minus itself. Adding a machine to the pool is one registry line plus one
  `enable`, and every existing member picks it up on its next switch.

- **Addresses stay inside the mesh.** Global discovery, local discovery and
  relays are off; peers are addressed as `tcp://<hostname>:22000`, resolvable
  because `networking-nebula` already writes every node into
  `networking.extraHosts` from `flake.nebulaNodes`. No public discovery server
  ever learns a device ID, and a laptop syncs from anywhere the lighthouse is
  reachable.

- **dapperehaan is the hub and the only NAS client.** It holds the folder as
  `receiveonly` with staggered versioning, so a deletion that propagates from a
  laptop is retained on the hub rather than erased everywhere at once. It gains
  `backup-restic-piethein` with a single `dapperehaan-work` dataset on the
  long-retention profile, and contributes `flake.resticRepos.dapperehaan`.

- **A shared ignore list.** `ignorePatterns` is set declaratively on the folder,
  so build output and dependency trees (`node_modules`, `.venv`, `target`,
  `.direnv`, `result`) never enter the pool and never reach restic.

## Capabilities

### Added Capabilities

- `syncthing-work-pool`: a named set of hosts keeps `/home/pim/Work` identical
  across every member over the nebula mesh, with one member holding the
  authoritative copy, retaining propagated deletions, and backing the folder up
  to the NAS. Membership is declared per host and peer configuration is derived
  from a single registry.

## Impact

- `modules/services/sync/syncthing-devices-option.nix`: new file. The
  `flake.syncthingDevices` registry option, modelled on
  `modules/services/networking/nebula-nodes-option.nix`.
- `modules/services/sync/syncthing-pool.nix`: new file. The
  `mipnix.syncthing.pool` options and the `syncthing-work-pool` NixOS module.
- `secrets/syncthing-<host>.crt.age` and `.key.age` for each member: new files.
- `secrets/secrets.nix`: recipients for the six new secrets.
- `modules/HOSTS/cichorei-laptop/configuration.nix`,
  `modules/HOSTS/doornappel-laptop/configuration.nix`: import the module, enable
  the pool, register the device ID.
- `modules/HOSTS/dapperehaan-server/configuration.nix`: the same, plus `hub =
  true`, plus `backup-restic-piethein` and the `dapperehaan-work` dataset and
  `flake.resticRepos.dapperehaan`.
- `modules/programs/desktop/utils/filesync.nix`: the commented-out `syncthing`
  package line is now answered by a real module; note it rather than leave it
  looking like the plan.
- No re-keying of existing secrets. `restic-ssh-key.age` and `restic-repo-pw.age`
  already list dapperehaan as a recipient (`secrets/secrets.nix:157`), so
  dapperehaan can back up without touching them.
- No firewall work. Every member already sets `networking.firewall.enable =
  false`, and the nebula firewall is `any/any/any` in both directions.

## Out of Scope

- **peterspav.** It is a pim desktop with `role-desktop-pim`, but
  `configuration.nix:40` has `role-nebula-node` commented out, so it has no route
  to the mesh. Restoring its nebula membership is its own change with its own
  reasons for having been disabled. Once it is back on the mesh, joining the pool
  is one registry line plus one `enable`.
- **lavendel.** It runs `role-desktop-annemarie` and `user-annemarie`. Not a pim
  machine.
- **`_lego2`.** The leading underscore excludes it from import-tree; it is not in
  `nixosConfigurations`.
- **ng-macbook, pesto-pinephone, nix-on-droid-fairphone.** nix-darwin,
  mobile-nixos and nix-on-droid respectively. None of them consume
  `flake.modules.nixos`, so each needs its own integration.
- **Moving `Documenten`, `Afbeeldingen` or `secondbrain` into the pool.** Work is
  the pilot. `secondbrain` in particular is already solved by git plus git-sync
  on dapperehaan (`linny-mcp.nix:92`) and should not gain a second sync
  mechanism.
- **Retiring the per-host `datasets` blocks.** The three defects in "Why" are the
  motivation for this shape; fixing them for data that is not in the pool is a
  separate change.
- **Syncthing's encrypted-untrusted-device feature.** `encryptionPasswordFile`
  exists, but a hub holding ciphertext makes its restic snapshots unbrowsable in
  Backrest, which defeats the point of having a restore console.

## Assumptions

These were open during exploration. They are answered here so the change is
actionable, and each is cheap to revise.

- **dapperehaan is reachable enough to be the hub.** Its root is LUKS-encrypted
  (`hardware.nix:22`), so after a power cut it stays down until someone enters
  the passphrase, taking both the sync hub and the only NAS client with it. This
  is the single point of failure the design introduces. It is accepted because
  the laptops still hold complete copies of the folder and keep syncing to each
  other; only the backups pause. Task 8.4 measures that case rather than assuming
  it.
- **The folder starts empty.** `/home/pim/Work` does not exist on any host, so
  there is no migration, no first-sync of an existing tree, and no conflict
  resolution on day one.
- **Certificates are generated once, by hand, per host.** There is no way to
  derive a device ID without a certificate, and no way to know it before that
  certificate exists. The generation is a one-time act per machine, done off the
  target host and committed, so the host itself never has an imperative step.
- **Staggered versioning, not trashcan.** Staggered thins old versions on its own
  schedule; trashcan keeps exactly one copy of a deleted file. Staggered fits a
  folder whose whole point is that several machines write to it.
- **The long-retention profile for `dapperehaan-work`.** The same list secondbrain
  and documents use: hourly 24, daily 7, weekly 5, monthly 12, yearly 9999. Work
  is the data this pool exists to not lose.
- **`receiveonly` on the hub is about the hub, not about deletions.** It stops
  anything edited on dapperehaan from propagating outward. It does not reject
  incoming deletions; versioning is what covers those. Both are configured, for
  different reasons.
- **The Samba share stays as it is.** dapperehaan imports `services-samba`, which
  shares `/home/pim` (`modules/services/samba.nix:10`), so `Work` becomes
  reachable over SMB on the LAN as a side effect. That is useful, and it also
  means an SMB client can delete into the pool. The versioning on the hub is what
  makes this acceptable.
