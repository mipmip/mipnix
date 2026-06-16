## Context

Durer runs NixOS 25.11 with nginx + ACME on `nuremberg.pimsnel.com` (ports 80/443) and Tuwunel Matrix on port 6167. The `pimsnel.com` DNS now points to durer's IP. NixOS 25.11 includes `services.bluesky-pds` module with full systemd hardening.

The PDS listens on a local port (default 3000) and expects a reverse proxy to handle TLS. It uses environment variables for configuration, with secrets loaded from environment files.

Durer already uses agenix for Nebula secrets, so the same pattern applies for PDS secrets.

## Goals / Non-Goals

**Goals:**
- Bluesky PDS at `pimsnel.com` with handle `@pimsnel.com`
- Nginx reverse proxy for PDS on a new `pimsnel.com` vhost with ACME
- Secrets managed via agenix (JWT secret, admin password, PLC rotation key)
- PDS admin tooling (`pdsadmin`) available on the server

**Non-Goals:**
- Running a relay or app view
- Custom feed generators
- Multiple user accounts (personal PDS)
- S3 blob storage (use local disk)

## Decisions

### 1. PDS_HOSTNAME = pimsnel.com

**Decision**: Use `pimsnel.com` as the PDS hostname, giving the handle `@pimsnel.com`.

**Rationale**: Clean handle. `pimsnel.com` DNS already points to durer.

### 2. Separate nginx vhost for pimsnel.com

**Decision**: Add a new nginx virtual host for `pimsnel.com` alongside the existing `nuremberg.pimsnel.com` vhost. The PDS vhost proxies `/xrpc/` and `/.well-known/` to PDS on port 3000.

**Rationale**: Keeps Matrix and PDS cleanly separated on different domains.

### 3. Secrets via agenix

**Decision**: Store PDS secrets as an agenix-encrypted file, decrypted to an environment file at `/run/agenix/pds-env`. The `services.bluesky-pds.environmentFiles` option points to this path.

**Secrets needed:**
- `PDS_JWT_SECRET` — random hex (openssl rand --hex 16)
- `PDS_ADMIN_PASSWORD` — random hex (openssl rand --hex 16)
- `PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX` — secp256k1 private key

### 4. Blob upload limit via nginx

**Decision**: Set `client_max_body_size` to at least 100MB on the pimsnel.com vhost to match the PDS default blob upload limit (100MB). The existing `clientMaxBodySize = "20m"` is global for nginx — we'll set a per-vhost override.

### 5. WebSocket support for PDS

**Decision**: The PDS uses WebSockets for streaming. Nginx proxy needs `Upgrade` and `Connection` headers forwarded.

## Risks / Trade-offs

- **[Handle permanence]** Once `@pimsnel.com` is registered with the PLC directory, changing the PDS hostname is complex (requires DID rotation). → Acceptable: `pimsnel.com` is a stable personal domain.
- **[Single server]** PDS data lives only on durer. → Mitigation: include `/var/lib/pds/` in backup strategy.
- **[PLC rotation key]** If lost, you lose the ability to migrate your DID. → Mitigation: back up the key separately, securely.
