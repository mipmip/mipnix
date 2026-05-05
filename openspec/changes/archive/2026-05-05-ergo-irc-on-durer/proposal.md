## Why

Durer currently has no communication infrastructure. An IRC server provides a lightweight, always-available messaging backbone — useful for personal notes, bot integrations, and ad-hoc communication. Ergo (ergo.chat) is a modern IRC server with built-in bouncer functionality, removing the need for a separate ZNC setup.

Related task: [mipnix-y4vw](../../.beans/mipnix-y4vw--ergoirc-on-durer.md)

## What Changes

- Deploy Ergo IRC server on durer (`nuremberg.pimsnel.com:6697`) with TLS
- Add nginx reverse proxy on ports 80/443 for ACME certificate management and a health check page for monitoring
- Configure SASL-required authentication with admin-only account registration
- Enable always-on bouncer mode so messages are buffered across disconnects
- Expand firewall to allow ports 80, 443, and 6697

## Capabilities

### New Capabilities
- `ergo-irc`: Ergo IRC server configuration — TLS, authentication, account management, bouncer mode, and server identity
- `durer-nginx-acme`: Nginx with ACME/Let's Encrypt on durer — certificate provisioning, health check endpoint, and cert sharing with other services

### Modified Capabilities
<!-- No existing spec-level requirements change -->

## Impact

- **Files modified**: `modules/HOSTS/durer-server/configuration.nix`, `modules/HOSTS/durer-server/networking.nix`
- **New files**: Possible new module(s) for ergo and nginx configuration
- **Firewall**: Ports 80, 443, 6697 opened on durer
- **DNS**: Requires `nuremberg.pimsnel.com` A record pointing to durer (assumed already in place)
- **Secrets**: No new agenix secrets needed — accounts are created via IRC operator commands, ACME is automated
- **Backup**: `/var/lib/ergo/ircd.db` should be included in backup strategy
