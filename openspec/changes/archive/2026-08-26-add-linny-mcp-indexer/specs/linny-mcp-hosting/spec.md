## ADDED Requirements

### Requirement: Corpus index is built before serving

The deployment SHALL build the corpus index before `linny-mcp serve` starts, so the
server never serves an empty index (the server itself does not build one).

#### Scenario: Index populated before serve starts

- **WHEN** the linny-mcp host starts (boot or redeploy)
- **THEN** a full `lindexer build` SHALL complete and populate the index in the state
  directory **before** `linny-mcp.service` starts, so MCP clients can query documents
  immediately

### Requirement: Index tracks corpus changes

The deployment SHALL keep the corpus index current as the corpus changes, including
edits pulled in from GitHub by git-sync (not only edits written by the server itself).

#### Scenario: Remote edit becomes searchable

- **WHEN** a note is edited elsewhere, pushed to `mipmip/secondbrain`, and pulled into
  `/var/lib/secondbrain` by git-sync
- **THEN** an index watcher (`lindexer watch`) SHALL rebuild the index so the edited
  note is searchable via MCP without any manual reindex

#### Scenario: Watcher recovers a correct index after restart

- **WHEN** the index service restarts (crash or redeploy)
- **THEN** it SHALL perform a full build before watching, re-establishing a correct
  index regardless of prior state

### Requirement: Generated index artifacts stay out of the corpus repo

The generated index (SQLite store and any JSON index) SHALL be written to the disposable
state directory, never into the git-tracked corpus, so git-sync does not commit or push
index artifacts.

#### Scenario: Index written to state dir only

- **WHEN** the index is built or refreshed
- **THEN** its SQLite and JSON outputs SHALL live under the linny-mcp state directory
  (e.g. `/var/lib/linny-mcp/personal`) and SHALL NOT appear as changes in the
  `/var/lib/secondbrain` git working tree
