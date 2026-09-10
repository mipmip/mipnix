## Purpose

Production hosting of startaste on the mesh: scheduled syncing of its sources,
an MCP endpoint reachable over TLS for Claude clients, a mesh-only dashboard,
and the state and credential handling those require.

## ADDED Requirements

### Requirement: startaste runs on dapperehaan from its own flake

startaste SHALL run on dapperehaan via the upstream `nixosModules.startaste` and its overlay, so the host consumes a released module rather than host-local packaging.

#### Scenario: Module and overlay are consumed upstream

- **WHEN** startaste is enabled on dapperehaan
- **THEN** the host SHALL import `inputs.startaste.nixosModules.startaste` and apply `inputs.startaste.overlays.default`, and SHALL NOT redefine the package or unit locally

#### Scenario: Upstream module is absent

- **WHEN** the startaste flake does not expose `nixosModules.startaste`
- **THEN** this deployment cannot be applied, and the upstream module is a prerequisite rather than something reimplemented here

### Requirement: Sync runs on a timer, not as an application loop

Syncing SHALL be driven by a `Type=oneshot` systemd unit invoking `startaste sync`, scheduled by a `systemd.timer`. The application MUST NOT be run as a long-lived process for the purpose of scheduling.

#### Scenario: Scheduled run

- **WHEN** the timer elapses
- **THEN** the oneshot unit runs `startaste sync`, and its output is recorded in the journal

#### Scenario: A run is still in progress

- **WHEN** the timer elapses while the previous run has not finished
- **THEN** systemd SHALL NOT start a second concurrent run

#### Scenario: A run fails

- **WHEN** a sync run exits non-zero
- **THEN** the failure is visible in the journal and the unit's restart policy applies, without blocking the next scheduled run

#### Scenario: Recovery after reboot

- **WHEN** dapperehaan reboots
- **THEN** the timer resumes on its own without manual intervention

### Requirement: MCP endpoint bound to the mesh, TLS terminated on durer

The MCP server SHALL listen only on dapperehaan's nebula mesh IP, and durer SHALL front it with an HTTPS reverse proxy so Claude Online and Claude Mobile reach it over TLS.

#### Scenario: Bound to the mesh IP

- **WHEN** the MCP service starts
- **THEN** it SHALL listen on `192.168.100.2:8766` and SHALL NOT bind a public address or `0.0.0.0`

#### Scenario: Public HTTPS endpoint

- **WHEN** a client requests `https://taste.pimsnel.com/mcp`
- **THEN** durer's nginx SHALL terminate TLS (ACME + forceSSL) and reverse-proxy the request over nebula to `http://192.168.100.2:8766`

#### Scenario: Streamable transport is not buffered

- **WHEN** the proxied request uses the MCP streamable-HTTP (SSE) transport
- **THEN** the vhost SHALL disable proxy buffering, use HTTP/1.1, and apply a long read timeout so long-lived streams are not stalled or truncated

#### Scenario: Port does not collide with linny-mcp

- **WHEN** both services run on dapperehaan
- **THEN** startaste's MCP port SHALL differ from linny-mcp's `8765`

### Requirement: MCP requests are authenticated, health checks are not

Requests to the MCP endpoint SHALL require a bearer token, while the health endpoint SHALL remain reachable without authentication.

#### Scenario: Unauthenticated MCP request

- **WHEN** a request to `/mcp` arrives without a valid `Authorization: Bearer` token
- **THEN** it SHALL be rejected

#### Scenario: Health check

- **WHEN** `/healthz` is requested without credentials
- **THEN** it SHALL respond, so the proxy and monitoring can probe it

### Requirement: The dashboard is reachable over the mesh only

The dashboard SHALL be published on the mesh IP with no public vhost, because it has no authentication of its own.

#### Scenario: Reachable from the mesh

- **WHEN** a host on the nebula overlay requests the dashboard on `192.168.100.2:8421`
- **THEN** it is served

#### Scenario: Not reachable publicly

- **WHEN** the durer configuration is applied
- **THEN** no public vhost SHALL proxy to the dashboard port, and the dashboard SHALL NOT bind a public address

### Requirement: State lives outside /home

The database, data and state directories SHALL be located under `/var/lib/startaste` so they are accessible inside the service sandbox, because the hardened unit sets `ProtectHome = true`.

#### Scenario: Paths are sandbox-accessible

- **WHEN** the services are configured
- **THEN** startaste's data, database and log locations SHALL be under `/var/lib/startaste` (not `/home`) and included in the units' `ReadWritePaths`

#### Scenario: Directories exist before start

- **WHEN** a unit starts for the first time
- **THEN** its state directories SHALL already exist, created declaratively, so bind-mounting a missing path cannot fail namespace setup

#### Scenario: All units share one database

- **WHEN** sync writes and the MCP server or dashboard reads
- **THEN** they SHALL operate on the same database file under `/var/lib/startaste`

### Requirement: Credentials come from encrypted files, never a .env

Source credentials and bearer tokens SHALL reach the services only as agenix-decrypted file paths. No credential value SHALL appear in a Nix option, and no `.env` file SHALL be relied upon.

#### Scenario: Source credentials

- **WHEN** the sync unit runs
- **THEN** `HN_COMMENTS_ACCT`, `HN_COMMENTS_PW` and `GITHUB_TOKEN` SHALL come from an `EnvironmentFile` pointing at an agenix-decrypted file owned by the service user

#### Scenario: Bearer token records

- **WHEN** the MCP service is configured
- **THEN** its token records SHALL come from an agenix-decrypted file, and no token literal SHALL be present in any Nix option or in `/nix/store`

#### Scenario: A .env would not be readable anyway

- **WHEN** the hardened unit runs with `ProtectHome = true`
- **THEN** a `.env` in a user's home is unreachable, so credentials MUST NOT be provisioned that way

### Requirement: Concurrent readers require WAL

Running a reader alongside the sync writer SHALL require the database to be in WAL journal mode.

#### Scenario: Reader during a write

- **WHEN** the MCP server or dashboard reads while a sync run holds a write transaction
- **THEN** the read SHALL succeed rather than failing with a locked database

#### Scenario: WAL not yet enabled upstream

- **WHEN** startaste still opens the database in rollback-journal mode
- **THEN** only the sync unit may be enabled, and enabling a second unit is deferred until WAL lands upstream
