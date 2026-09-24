# Syncthing Work Pool

## ADDED Requirements

### Requirement: declared-membership

Belonging to the pool SHALL be a property a host declares in one place, and a
host that has not declared it SHALL run no pool service and hold no pool folder.

A host SHALL NOT be able to import the pool module and end up silently
inactive: if the module is imported without membership being declared, that is
the same as not importing it, and the host's configuration SHALL show which of
the two it is without the reader having to trace an enable flag through another
module.

#### Scenario: a member host

- **WHEN** a host declares pool membership and is built
- **THEN** the sync service SHALL be enabled on that host and the shared folder
  SHALL be configured

#### Scenario: a non-member host

- **WHEN** a host does not declare pool membership
- **THEN** no sync service SHALL be enabled and no pool folder SHALL exist on it

#### Scenario: membership is visible

- **WHEN** a reader inspects a host's configuration
- **THEN** whether that host is a pool member SHALL be answerable from that file
  alone

### Requirement: derived-peer-configuration

Each member SHALL learn its peers from a single registry of member identities,
and SHALL NOT restate any other member's identity or address.

A member's peer set SHALL be every registered member except itself.

#### Scenario: peers are complete

- **WHEN** a member is built
- **THEN** every other registered member SHALL appear in its peer configuration

#### Scenario: a member does not peer with itself

- **WHEN** a member is built
- **THEN** its own identity SHALL NOT appear in its own peer configuration

#### Scenario: adding a member

- **WHEN** a new host is added to the registry and declares membership
- **THEN** every existing member SHALL gain that peer on its next build, with no
  edit to any existing member's own configuration

#### Scenario: the registry does not force system evaluation

- **WHEN** the registry is read
- **THEN** it SHALL yield plain values without evaluating any host's full system
  configuration, so that members can read it without a cycle

### Requirement: declarative-device-identity

A member's sync identity SHALL be provisioned declaratively, so that a freshly
built host joins the pool without any step performed on that host.

The identity material SHALL be stored encrypted in the repository, and SHALL NOT
be generated on the target host at first start.

#### Scenario: first boot of a rebuilt member

- **WHEN** a member host is built and started for the first time
- **THEN** it SHALL present its registered identity, and its peers SHALL
  recognise it without any manual approval step

#### Scenario: identity is not left to the host

- **WHEN** a member starts
- **THEN** it SHALL use the identity material supplied by the configuration, and
  SHALL NOT use a self-generated one

#### Scenario: identity material is not readable in the repository

- **WHEN** the repository is inspected
- **THEN** the private half of each member's identity SHALL be encrypted

### Requirement: shared-work-folder

Every member SHALL hold the same folder at the same path, and a change made on
one member SHALL reach every other reachable member without user action.

#### Scenario: a file created on one member

- **WHEN** a file is created in the folder on one member and another member is
  reachable
- **THEN** that file SHALL appear in the folder on the other member

#### Scenario: a change made on one member

- **WHEN** an existing file is modified on one member
- **THEN** the modification SHALL reach every other reachable member

#### Scenario: a member that was offline

- **WHEN** a member is unreachable while changes are made elsewhere, and later
  becomes reachable
- **THEN** it SHALL converge on the current contents of the folder

#### Scenario: concurrent edits

- **WHEN** the same file is edited on two members while they cannot reach each
  other
- **THEN** both versions SHALL be preserved, one of them under a distinct
  conflict name, and neither SHALL be discarded

### Requirement: mesh-only-transport

Pool traffic SHALL travel only over the private mesh, and member identities
SHALL NOT be announced to any third party.

Members SHALL be addressed by mesh hostname rather than by a restated address
literal.

#### Scenario: no public announcement

- **WHEN** a member runs
- **THEN** it SHALL NOT announce itself to any public discovery service and SHALL
  NOT use any relay

#### Scenario: a member away from the home network

- **WHEN** a member is connected to an unfamiliar network and can reach the mesh
- **THEN** it SHALL sync with the other members

#### Scenario: addresses are not restated

- **WHEN** the pool configuration is inspected
- **THEN** no member's network address SHALL be written as a literal in the pool
  configuration

### Requirement: excluded-content

The folder SHALL exclude build output and dependency directories, identically on
every member, and that exclusion SHALL be part of the repository rather than
per-machine state.

#### Scenario: excluded directories do not propagate

- **WHEN** an excluded directory is created inside the folder on one member
- **THEN** it SHALL NOT be transferred to any other member

#### Scenario: exclusions are identical across members

- **WHEN** two members are built
- **THEN** both SHALL apply the same exclusion list

#### Scenario: exclusions survive a local edit

- **WHEN** the exclusion list is changed outside the repository on a member and
  the service restarts
- **THEN** the list from the repository SHALL be in force

### Requirement: authoritative-copy

Exactly one member SHALL be designated as holding the authoritative copy. That
member SHALL NOT propagate changes made locally on it, and SHALL retain the
previous contents of files that are deleted or replaced by changes arriving from
other members.

#### Scenario: a local change on the authoritative member

- **WHEN** a file in the folder is modified directly on the authoritative member
- **THEN** that modification SHALL NOT propagate to the other members

#### Scenario: a deletion arriving from another member

- **WHEN** a file is deleted on another member and that deletion reaches the
  authoritative member
- **THEN** the previous contents SHALL be retained on the authoritative member
  and SHALL be recoverable

#### Scenario: a replacement arriving from another member

- **WHEN** a file is overwritten on another member and the change reaches the
  authoritative member
- **THEN** the previous version SHALL be retained on the authoritative member

### Requirement: single-backup-source

The folder SHALL be backed up from the authoritative member only, and from no
other member.

The backup SHALL use the repository's existing backup mechanism and SHALL
contribute its repository name to the aggregated registry that the restore
console reads.

#### Scenario: the authoritative member backs up

- **WHEN** the authoritative member is built
- **THEN** a scheduled backup of the folder SHALL be configured on it

#### Scenario: other members do not back up the folder

- **WHEN** a non-authoritative member is built
- **THEN** it SHALL NOT be configured to back up the folder

#### Scenario: the repository appears in the restore console

- **WHEN** the restore console's repository list is generated
- **THEN** it SHALL include the folder's backup repository

#### Scenario: a deleted file is recoverable from backup

- **WHEN** a file has been deleted across the pool and a backup taken before the
  deletion is inspected
- **THEN** that file SHALL be present in it

### Requirement: degraded-operation

The pool SHALL keep working, in the ways it still can, when the authoritative
member is unavailable.

#### Scenario: members sync without the authoritative member

- **WHEN** the authoritative member is down and two other members are reachable
  to each other
- **THEN** they SHALL continue to sync with each other

#### Scenario: the authoritative member returns

- **WHEN** the authoritative member becomes available again after being down
- **THEN** it SHALL converge on the current contents and resume backing up

#### Scenario: no member is blocked by an unreachable peer

- **WHEN** a member cannot reach some peers
- **THEN** it SHALL continue to serve and accept changes from the peers it can
  reach

### Requirement: declarative-provisioning

The pool SHALL be provisioned entirely by the repository: no step performed on a
member host, and nothing configured through the service's own web interface,
SHALL be required for the pool to work or SHALL survive a restart.

#### Scenario: after a rebuild

- **WHEN** a member is rebuilt and restarted
- **THEN** its peers, folder and exclusions SHALL match the repository

#### Scenario: a change made outside the repository

- **WHEN** a peer or folder is added on a member outside the repository and the
  service restarts
- **THEN** the repository's configuration SHALL be in force
