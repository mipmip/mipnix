## Context

Durer is a headless NixOS server (25.11) accessible at `nuremberg.pimsnel.com` and via the Nebula mesh at `192.168.100.12`. It currently runs SSH and Nebula only. The NixOS config already has `services.ergochat.enable = true` but no settings beyond the default.

The NixOS `services.ergochat` module exposes a `settings` attrset that maps directly to Ergo's YAML config. It runs as a DynamicUser with state in `/var/lib/ergo/`. The module also supports `configFile` for a raw YAML path, but `settings` is preferred for declarative management.

## Goals / Non-Goals

**Goals:**
- Encrypted IRC server on `nuremberg.pimsnel.com:6697` with auto-renewing TLS certs
- Authentication-only access (SASL required, no anonymous users)
- Admin-managed accounts (no self-registration)
- Always-on bouncer mode for message replay across disconnects
- Health check endpoint on HTTPS for monitoring
- Declarative NixOS configuration (no manual setup beyond initial account creation)

**Non-Goals:**
- Federation with other IRC networks
- Web IRC client (e.g., The Lounge, Kiwi IRC)
- Custom IRC bots (can be added later independently)
- Public registration or open access
- High-availability or replication

## Decisions

### 1. ACME via nginx with HTTP-01 challenge

**Decision**: Run nginx on ports 80/443 with NixOS `security.acme` for Let's Encrypt certificates. Ergo reads certs from the ACME directory.

**Alternatives considered**:
- *DNS-01 challenge*: Doesn't require port 80 but needs DNS provider API integration — unnecessary complexity for a single host.
- *Self-signed certs*: Would require clients to trust a custom CA. Unacceptable for connections from outside the Nebula mesh.

**Approach**: NixOS `security.acme.certs."nuremberg.pimsnel.com"` with nginx as the ACME web server. The `ergo` service user is added to the `acme` group to read cert files. Ergo's TLS listener at `:6697` references `/var/lib/acme/nuremberg.pimsnel.com/{fullchain.pem,key.pem}`.

### 2. Ergo configuration via services.ergochat.settings

**Decision**: Use the declarative `settings` attrset rather than a raw config file.

**Rationale**: Keeps everything in Nix, benefits from type checking, and follows the existing pattern of the host config.

### 3. SASL-required with admin-only registration

**Decision**: Set `require-sasl.enabled = true` and `accounts.registration.enabled = false`.

**Approach**: Initial account creation via IRC oper commands (`/OPER` then `/NS SAREGISTER`). The oper password is set in Ergo's settings as a bcrypt hash. This avoids needing agenix secrets for account management — the hash is safe to store in the Nix config.

### 4. Always-on bouncer mode (opt-out)

**Decision**: Enable always-on by default since this is a single-user server.

**Setting**: `accounts.multiclient.always-on = "opt-out"` — on by default, can be disabled per-account if needed.

### 5. Health check page

**Decision**: nginx serves a minimal static page at `https://nuremberg.pimsnel.com/` for uptime monitoring.

**Approach**: A simple `200 OK` response with server identity. No dynamic content.

## Risks / Trade-offs

- **[Cert reload]** Ergo needs to pick up renewed certs. → Mitigation: ACME renewal hook sends SIGHUP to Ergo (the NixOS module supports reload via SIGHUP).
- **[Port 80 exposure]** HTTP is open for ACME challenges. → Mitigation: nginx only serves ACME challenge responses on port 80, redirects everything else to HTTPS.
- **[Single point of failure]** SQLite DB is the only state. → Mitigation: Include `/var/lib/ergo/ircd.db` in backup strategy. Ergo can recreate the DB from scratch if needed (accounts would need re-creation).
- **[Oper password in nix store]** The bcrypt hash is in the Nix config, which ends up in `/nix/store`. → Acceptable: bcrypt hashes are designed to be safe to expose. The plaintext oper password is never stored.
