## Context

See `proposal.md` for motivation. The constraints that shape the approach, all
verified while exploring.

**The mesh already does the hard part.** `modules/services/networking/nebula.nix`
gives every node:

```
  lighthouse      durer 192.168.100.12  ->  nuremberg.pimsnel.com:4242
  name resolution networking.extraHosts, derived from flake.nebulaNodes, so
                  every node has "192.168.100.2 dapperehaan" in /etc/hosts
  firewall        inbound and outbound both any/any/any
```

So port 22000 needs no opening, peers can be addressed by name rather than by IP
literal, and a laptop anywhere in the world reaches the mesh through the
lighthouse. Every candidate member also sets `networking.firewall.enable = false`
at the host level, so `openDefaultPorts` is irrelevant.

**Registry membership, verified:**

```
  flake.nebulaNodes            cichorei 100.13   doornappel 100.15
                               dapperehaan 100.2 durer 100.12 (lighthouse)
                               harry 100.7  hurry 100.6  lavendel 100.10
                               zonnehoed 100.14
  nixosConfigurations          cichorei dapperehaan doornappel durer harry
                               hurry lavendel peterspav pinephone zonnehoed
                               (no lego2: the leading underscore excludes it
                               from import-tree)
  role-desktop-pim             cichorei doornappel peterspav (_lego2)
  peterspav                    role-nebula-node commented out, so no mesh route
  lavendel                     role-desktop-annemarie, not a pim machine
```

Which leaves cichorei, doornappel and dapperehaan as the members this change can
actually ship.

**The syncthing NixOS module, options verified against the pinned nixpkgs**
(`nixos/modules/services/networking/syncthing.nix`):

```
  cert / key                    :342 / :351   agenix can own the identity
  settings.devices.<n>.id       :496
  settings.devices.<n>.*        freeform, so `addresses` passes through
  settings.folders.<n>.type     :585          sendreceive | receiveonly | ...
  settings.folders.<n>.versioning :640
  settings.folders.<n>.ignorePatterns :713    declarative .stignore
  overrideDevices / overrideFolders :368/:379 default true
  guiAddress                    :774          default 127.0.0.1:8384
  systemService                 :783          default true
  dataDir                       :824          default /var/lib/syncthing
  openDefaultPorts              :871          default false
```

Two of those decide the design. `cert`/`key` make the identity declarable, which
is what removes the GUI bootstrap. `ignorePatterns` makes the ignore list part of
the repo rather than a file someone has to remember to copy onto each machine.

**dapperehaan's existing position:**

```
  192.168.2.22 on piethein's LAN (192.168.2.100), so SFTP is direct, no relay
  100.2 on nebula
  already declares age.secrets.restic-ssh-key and restic-repo-pw (backrest.nix:99)
  already a recipient of both (secrets/secrets.nix:157), so no re-keying
  does NOT import backup-restic-piethein
  imports services-samba, which shares /home/pim (samba.nix:10)
  imports system-default, which brings user-pim, so /home/pim exists
  root is LUKS (hardware.nix:22)
```

So making dapperehaan a backup source is an import plus one dataset, not a
secrets exercise.

## Goals / Non-Goals

**Goals**

- `/home/pim/Work` is the same tree on every pool member, kept in step without
  anyone running a command.
- A member is a member because a host declares it, visibly, in one place.
- Adding a machine costs one registry line and one `enable`, with no edit to any
  existing member.
- The folder is backed up from exactly one host, and an accidental deletion
  somewhere in the pool is recoverable.
- No sync traffic and no device identity leaves the nebula mesh.

**Non-Goals**

- Replacing the per-host restic `datasets` blocks for data outside the pool.
- Supporting a host that is not on the nebula mesh. Mesh membership is the
  prerequisite, not something this module works around.
- Conflict resolution beyond what Syncthing does on its own. Two machines editing
  the same file offline produces a `.sync-conflict-` file, and that is the
  expected outcome, not a defect to engineer away.
- A general file-sync capability. This is one folder with one purpose.

## Identity, and why it is the crux

A Syncthing device ID is a hash of that device's TLS certificate. Every member
needs every other member's ID. So an ID must exist in the repo before the host
ever starts Syncthing, or the pool is assembled by hand in a web UI.

The repo already solves this shape for nebula, and the parallel is exact:

```
  nebula                              syncthing
  ------                              ---------
  secrets/nebula-<host>.crt.age       secrets/syncthing-<host>.crt.age
  secrets/nebula-<host>.key.age       secrets/syncthing-<host>.key.age
        |                                   |
        v                                   v
  services.nebula.networks.mesh       services.syncthing.cert
    .cert / .key                        services.syncthing.key
        |                                   |
        v                                   v
  flake.nebulaNodes.<host> = IP       flake.syncthingDevices.<host> = ID
  (plain strings, no system eval)     (same)
```

`flake.syncthingDevices` is the third instance of a pattern the repo already
runs twice (`flake.nebulaNodes`, `flake.resticRepos`). It carries plain strings
for the same reason they do: a consumer must be able to read it without forcing
`nixosConfigurations`.

Here the consumer is the module itself, computing its peer list. Reading peers
from other hosts' evaluated configuration would mean every member evaluates
every other member, which is a cycle as soon as two members are in the pool. The
registry breaks it by construction.

## Flow

```
  build time
  ----------
  flake.syncthingDevices = { cichorei = "ABC..."; doornappel = "DEF...";
                             dapperehaan = "GHI..."; }
         |
         |  peers = registry minus networking.hostName
         v
  services.syncthing.settings.devices = {
      doornappel  = { id = "DEF..."; addresses = [ "tcp://doornappel:22000" ]; };
      dapperehaan = { id = "GHI..."; addresses = [ "tcp://dapperehaan:22000" ]; };
  }                                     ^
                                        name resolves via networking.extraHosts


  run time
  --------
     cichorei                doornappel
   /home/pim/Work          /home/pim/Work
   sendreceive             sendreceive
        \                      /
         \                    /     nebula, tcp 22000
          \                  /      no global announce
           \                /       no local announce
            \              /        no relays
             v            v
          +----------------------+
          |     dapperehaan      |
          |   /home/pim/Work     |
          |   receiveonly        |
          |   versioning:        |
          |     staggered        |  -> .stversions/ keeps propagated deletes
          +----------+-----------+
                     |
                     | hourly restic, sftp direct on the LAN
                     v
          piethein:/ResticBackups/dapperehaan-work
          keep: hourly 24, daily 7, weekly 5, monthly 12, yearly 9999
                     |
                     v
          Backrest console (reads flake.resticRepos)
```

## Decisions

### The hub is `receiveonly` AND versioned, for two different reasons

They are often conflated. `receiveonly` stops anything changed on dapperehaan
from propagating outward, which matters because `/home/pim` there is also a
Samba share: an SMB client browsing the tree cannot accidentally push a change
into the pool.

It does nothing about deletions arriving from a laptop. Syncthing applies those
like any other change, so without versioning the window between "deleted on
cichorei" and "next restic run" is up to an hour in which no copy of the file
exists anywhere. Staggered versioning closes that window at the hub, immediately,
independently of the backup schedule.

Both are configured. Neither substitutes for the other.

### Nebula-only addressing

`globalAnnounceEnabled`, `localAnnounceEnabled` and `relaysEnabled` all off,
with explicit `tcp://<hostname>:22000` addresses.

What this buys: no public discovery server is told which device IDs exist or
which addresses they answer on, and the sync path is the mesh you already trust
and already run. What it costs: two laptops on the same café wifi route through
the mesh rather than finding each other locally, and a host that is not in the
registry is invisible even if it is sitting on the same network. Both costs are
acceptable given the mesh exists specifically so these machines can reach each
other from anywhere.

Addresses use the hostname rather than the nebula IP because
`networking-nebula` already writes `flake.nebulaNodes` into
`networking.extraHosts` on every node. Using the name means the IP literal is
stated in exactly one place in the repo, which is the rule the nebula module set
for itself.

### `hub` is a separate flag from `enable`

`mipnix.syncthing.pool.enable` makes a host a member.
`mipnix.syncthing.pool.hub` makes it the authoritative copy: `receiveonly`,
versioning, and the restic dataset.

Keeping them separate means the hub role can move to another always-on host by
moving one boolean, and it makes "who backs this up" a visible property rather
than something inferred from which host happens to have a datasets block.

### The dataset lives on the host, not in the module

`flake.resticRepos.dapperehaan = [ "dapperehaan-work" ]` and the
`mipnix.backup.piethein.datasets` entry stay in dapperehaan's own file, matching
every other backup host in the repo. The pool module does not reach into the
backup module.

The alternative, having `hub = true` set the dataset itself, would hide a repo
name from the flake-level registry that Backrest reads, and would couple two
modules that currently know nothing about each other.

### Declarative ignore patterns, not a copied `.stignore`

A `Work` folder that carries `node_modules`, `.venv`, `target/`, `.direnv` and
`result` symlinks across three machines is the standard way this arrangement
becomes unusable: constant churn, large transfers, and platform-specific
binaries syncing onto the wrong architecture. It also lands in restic, where it
is retained for a year.

`ignorePatterns` puts the list in the repo, identical on every member, reviewed
like any other change. `overrideFolders` defaults to true, so a pattern added
through the web UI is reverted on the next restart, which is the intended
behaviour here.

## Risks / Trade-offs

- **dapperehaan is a single point of failure for backups.** LUKS root means a
  power cut leaves it down until someone types the passphrase. While it is down:
  the laptops keep syncing to each other and keep full copies, but nothing
  reaches the NAS. This is strictly better than today for Work (which has no
  backup at all) and strictly worse than a hub that boots unattended. Task 8.4
  exercises the case.

- **Sync propagates mistakes at wire speed.** Three machines agreeing on a
  deletion is not redundancy. The mitigation is versioning at the hub, and its
  effectiveness depends on the staggered schedule chosen. This is the risk the
  design exists to manage, not one it removes.

- **The Samba share widens the write surface.** `/home/pim` on dapperehaan is
  shared, so `Work` is writable over SMB by anyone on the LAN who can
  authenticate. `receiveonly` means those writes do not propagate, but they do
  get backed up, and a delete over SMB still removes the hub's copy. Versioning
  covers it.

- **A member that never runs accumulates divergence.** A laptop switched off for
  months rejoins and replays every change. Normal Syncthing behaviour, but the
  first sync after a long absence is not instant and can surface conflicts.

- **Certificate loss means a new device ID.** If a member's key is lost, its
  replacement is a different device and must be re-registered everywhere. The
  keys are in agenix, so this is a restore problem rather than a regeneration
  problem, but it is worth knowing that the ID is not recoverable from anything
  else.

- **`overrideDevices` and `overrideFolders` are on.** Anything added through the
  web UI disappears on restart. Intended, and surprising the first time it
  happens.

## Open Questions

None blocking. Two worth revisiting once the pool has run for a while:

- Whether the staggered versioning schedule is generous enough, which only real
  usage answers.
- Whether `Documenten` and `Afbeeldingen` should follow Work into the pool, which
  would retire several per-host datasets blocks. Deliberately out of scope here.
