# startaste-hosting Specification

## Purpose
How startaste is hosted across dapperehaan and durer: the units that run, what
they bind, where the database and credentials live, and the public HTTPS endpoint
that fronts the MCP server for Claude Online and Claude Mobile.

## Requirements

### Requirement: startaste is consumed from upstream, not repackaged

The deployment SHALL obtain both the service definition and the package from the
upstream startaste flake, so mipnix carries host wiring only and no packaging or
unit definitions of its own.

#### Scenario: Module and overlay come from the flake

- **WHEN** startaste is configured on a host
- **THEN** the host SHALL import the upstream flake's NixOS module attribute and
  apply its default overlay, and SHALL NOT define its own startaste package or
  systemd units

#### Scenario: Upstream option surface is used as-is

- **WHEN** sync, the MCP server, or the dashboard is enabled
- **THEN** it SHALL be enabled through the upstream `services.startaste` options
  rather than by hand-written units alongside them

### Requirement: The MCP server runs on dapperehaan bound to the mesh

The startaste MCP server SHALL run on dapperehaan bound to dapperehaan's nebula
mesh IP, so it is reachable only over the overlay and never on a public interface.
TLS terminates upstream on durer.

#### Scenario: Bound to the mesh IP

- **WHEN** the MCP server is enabled on dapperehaan
- **THEN** it SHALL listen on `192.168.100.2:8766` and SHALL NOT bind a public
  address or `0.0.0.0`

#### Scenario: No collision with linny-mcp

- **WHEN** both MCP servers run on dapperehaan
- **THEN** startaste SHALL use a port distinct from linny-mcp's `8765`, and
  enabling one SHALL NOT disturb the other

### Requirement: Sources are synced on a schedule owned by systemd

The collection SHALL be refreshed periodically by the upstream module's oneshot
unit and timer, with no application-level interval loop, and with a first run
shortly after boot rather than a full interval later.

#### Scenario: Periodic refresh

- **WHEN** the host has been running for longer than the configured interval
- **THEN** a sync run SHALL have been performed at that interval, and new stars
  and upvotes SHALL be present in the database

#### Scenario: Overlapping tick

- **WHEN** the timer elapses while a previous sync run is still in progress
- **THEN** a second concurrent run SHALL NOT be started

#### Scenario: A failing run does not stop the schedule

- **WHEN** a sync run exits non-zero (for example a source's credentials are
  rejected)
- **THEN** the failure SHALL be visible in the journal and the next scheduled run
  SHALL still happen

### Requirement: The MCP server tolerates an empty host

The MCP server opens the database read-only and never creates one, so on a host
that has not yet synced it cannot serve. The deployment SHALL let it retry
indefinitely until the first sync has produced a database, rather than failing
permanently or requiring a manual restart.

#### Scenario: First deploy, before any sync

- **WHEN** the MCP server starts on a host whose database does not exist yet
- **THEN** it SHALL exit with a clear error, SHALL be restarted on a fixed delay
  without exhausting a start limit, and SHALL begin serving once the first sync
  has created the database

#### Scenario: Public endpoint during the gap

- **WHEN** a client requests the public MCP URL before the first sync completes
- **THEN** the request SHALL fail at the proxy rather than returning a
  half-initialised or empty-database success

### Requirement: TLS terminates on durer and proxies over nebula

durer SHALL front the MCP server with an HTTPS reverse proxy so external clients
reach it over TLS while the server itself stays on the mesh.

#### Scenario: Public HTTPS endpoint

- **WHEN** a client requests `https://taste.pimsnel.com/mcp`
- **THEN** durer's nginx SHALL terminate TLS (ACME + forceSSL) and reverse-proxy
  the request over nebula to `http://192.168.100.2:8766`

#### Scenario: Streamable transport is not buffered

- **WHEN** the proxied request uses the MCP streamable-HTTP (SSE) transport
- **THEN** the vhost SHALL disable proxy buffering, use HTTP/1.1, and apply a long
  read timeout so long-lived streams are not stalled or truncated

#### Scenario: Health endpoint is reachable without credentials

- **WHEN** the service's health endpoint is requested through the public vhost
  with no `Authorization` header
- **THEN** it SHALL respond, and its body SHALL NOT disclose collection contents

### Requirement: The dashboard is reachable only over the mesh

The web dashboard has no authentication of any kind. It SHALL therefore be bound
to dapperehaan's mesh IP and SHALL NOT be fronted by any public vhost.

#### Scenario: Bound to the mesh

- **WHEN** the dashboard is enabled
- **THEN** it SHALL listen on `192.168.100.2:8421` and SHALL NOT bind a public
  address or `0.0.0.0`

#### Scenario: Not published

- **WHEN** durer's vhosts are inspected
- **THEN** no vhost SHALL proxy to the dashboard port, so the dashboard is
  reachable only from nodes on the nebula overlay

#### Scenario: Ports are distinct

- **WHEN** the dashboard and the MCP server are both enabled
- **THEN** they SHALL listen on different ports

### Requirement: Source credentials reach the units only as an encrypted file path

Source credentials SHALL be supplied as a path to an agenix-decrypted file, never
as a Nix option value, and SHALL NOT rely on the application's own `.env`
discovery — the hardened units set `ProtectHome = true` and resolve `.env` from
the working directory, so a `.env` is unreachable.

#### Scenario: Credentials come from agenix

- **WHEN** the service is configured
- **THEN** the credentials file SHALL be an agenix secret (`startaste-env`) owned
  by the service user, and no credential literal SHALL appear in any Nix option
  or in `/nix/store`

#### Scenario: File is consumable by systemd

- **WHEN** the credentials file is written
- **THEN** it SHALL be plain `KEY=value` lines that systemd's `EnvironmentFile`
  accepts — no `export` prefixes, no inline comments after values, and no reliance
  on shell expansion

#### Scenario: Only configured sources are synced

- **WHEN** credentials are present for some sources and absent for others
- **THEN** sync SHALL process the configured sources and report the others as
  unconfigured, rather than failing the whole run

### Requirement: Bearer tokens sourced from an encrypted file, one per client

Bearer tokens SHALL be provided to the MCP server only as a path to an
agenix-decrypted file of hashed records; no token value SHALL appear in a Nix
option. Each client SHALL have its own record so that one can be revoked without
affecting the others.

#### Scenario: Token records come from agenix

- **WHEN** the MCP server is configured
- **THEN** its tokens file SHALL point at an agenix secret
  (`startaste-mcp-tokens`) owned by the service user, holding records of name and
  token hash, with no raw token recoverable from the file

#### Scenario: Unauthenticated requests are rejected

- **WHEN** a request to `/mcp` arrives without a valid `Authorization: Bearer`
  token
- **THEN** it SHALL be rejected, while the health endpoint SHALL remain reachable
  without auth

#### Scenario: Per-client revocation

- **WHEN** one client's record is removed and the host is redeployed
- **THEN** that client SHALL be rejected and every other client SHALL continue to
  work

### Requirement: State lives outside /home

The database, data directory and log SHALL live under `/var/lib` so they are
accessible inside the service sandbox, because the hardened units set
`ProtectHome = true`.

#### Scenario: State is sandbox-accessible

- **WHEN** the service is configured
- **THEN** its data directory, database and log SHALL resolve under
  `/var/lib/startaste` and SHALL be writable by the service user while the rest of
  the filesystem is not

#### Scenario: Directories exist before first start

- **WHEN** a unit starts for the first time on dapperehaan
- **THEN** its state directories SHALL already exist owned by the service user, so
  the unit does not fail while setting up its namespace

#### Scenario: Sync and MCP share one database

- **WHEN** a sync run writes and the MCP server reads
- **THEN** both SHALL operate on the same database file, and a read SHALL succeed
  while a sync holds a write transaction
