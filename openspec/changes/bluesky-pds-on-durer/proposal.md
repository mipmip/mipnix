## Why

Running a personal AT Protocol PDS (Personal Data Server) gives full ownership of Bluesky social data — posts, likes, follows, and media are stored on your own infrastructure. With `pimsnel.com` DNS pointing to durer, the handle `@pimsnel.com` becomes possible — a clean, professional identity on the AT Protocol network.

## What Changes

- Deploy Bluesky PDS on durer using `services.bluesky-pds` NixOS module
- Add nginx vhost for `pimsnel.com` with ACME/Let's Encrypt, proxying `/xrpc/*` and `/.well-known/*` to PDS on port 3000
- Configure `PDS_HOSTNAME = "pimsnel.com"` for the `@pimsnel.com` handle
- Store PDS secrets (JWT secret, admin password, PLC rotation key) in an environment file on durer
- Open no new firewall ports (reuses existing 80/443)

## Capabilities

### New Capabilities
- `bluesky-pds`: Bluesky PDS configuration — service setup, hostname identity, secrets, and admin tooling
- `durer-nginx-pimsnel`: Nginx vhost for pimsnel.com — ACME cert, PDS reverse proxy, and AT Protocol well-known endpoints

### Modified Capabilities
<!-- No existing spec-level requirements change -->

## Impact

- **Files modified**: `modules/HOSTS/durer-server/configuration.nix` (PDS service + nginx vhost)
- **New DNS**: `pimsnel.com` A record pointing to durer (already done by user)
- **Secrets**: `/var/lib/pds/pds.env` on durer containing `PDS_JWT_SECRET`, `PDS_ADMIN_PASSWORD`, `PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX`
- **Storage**: `/var/lib/pds/` for SQLite database + blob storage
- **Backup**: `/var/lib/pds/` should be included in backup strategy
