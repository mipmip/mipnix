## Context

Durer already runs nginx with ACME on `nuremberg.pimsnel.com` (ports 80/443) and Ergo IRC on port 6697. Adding a Matrix homeserver means adding Tuwunel behind the existing nginx reverse proxy — no new ports or certificates needed.

NixOS 25.11 has a dedicated `services.matrix-tuwunel` module with options for `server_name`, `port`, `allow_registration`, `allow_federation`, `allow_encryption`, and freeform TOML settings. It creates a `tuwunel` system user and stores state in `/var/lib/tuwunel/`. The service listens on localhost:6167 by default.

## Goals / Non-Goals

**Goals:**
- Matrix homeserver on `nuremberg.pimsnel.com` accessible via `/_matrix/` on port 443
- Private server: no open registration, no federation
- Admin-managed accounts
- End-to-end encryption enabled
- Reuse existing nginx + ACME infrastructure

**Non-Goals:**
- Federation with other Matrix homeservers (can be enabled later)
- Bridges to other messaging platforms
- Web-based Matrix client (Element Web, etc.)
- High-availability or database replication

## Decisions

### 1. Use `services.matrix-tuwunel` module

**Decision**: Use the dedicated NixOS module for Tuwunel.

**Alternatives considered**:
- *`services.matrix-conduit` with package override*: Would work but is a hack. The dedicated module has proper user/group management and Tuwunel-specific options.

### 2. Nginx reverse proxy on existing vhost

**Decision**: Add `/_matrix/` and `/.well-known/matrix/` location blocks to the existing `nuremberg.pimsnel.com` nginx vhost, proxying to `localhost:6167`.

**Rationale**: No new ports, no new certs. Matrix clients discover the server via `.well-known` at the server name's domain.

### 3. Server name considerations

**Decision**: Use `nuremberg.pimsnel.com` as `server_name`.

**Important**: The `server_name` in Matrix is permanent — it becomes part of every user ID (`@pim:nuremberg.pimsnel.com`) and room ID. It cannot be changed after the first user is created. This is acceptable for a personal server.

### 4. Registration disabled, admin CLI for account creation

**Decision**: Set `allow_registration = false`. Create accounts via `tuwunel` CLI on the server.

**Approach**: SSH into durer and use the Tuwunel admin command to create the initial account.

### 5. No federation

**Decision**: Set `allow_federation = false` and `trusted_servers = []`.

**Rationale**: Personal server, no need to communicate with other homeservers. Can be enabled later without data migration.

## Risks / Trade-offs

- **[Server name is permanent]** Once users/rooms exist, `server_name` can never change. → Acceptable: `nuremberg.pimsnel.com` is a stable domain.
- **[Database in /var/lib/tuwunel/]** Default SQLite-like storage (RocksDB). → Mitigation: include in backup strategy.
- **[No federation]** Can't join public Matrix rooms. → Intentional for initial deployment.
