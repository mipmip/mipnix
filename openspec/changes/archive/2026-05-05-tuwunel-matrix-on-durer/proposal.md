## Why

A Matrix homeserver provides modern messaging capabilities — end-to-end encryption, rich media, message sync across devices, and push notifications — that complement the existing IRC setup on durer. Tuwunel (successor to conduwuit) is a lightweight, single-binary Rust Matrix server that fits durer's low-resource profile. OpenClaw will connect to it as a client.

Related task: [mipnix-eurx](../../.beans/mipnix-eurx--tuwunel-matrix-on-durer.md)

## What Changes

- Deploy Tuwunel Matrix homeserver on durer, listening on a local port behind nginx
- Add nginx reverse proxy for Matrix client API (`/_matrix/`) on `nuremberg.pimsnel.com:443`
- Disable federation and open registration (private, admin-only accounts)
- Admin account creation via Tuwunel CLI or admin API

## Capabilities

### New Capabilities
- `tuwunel-matrix`: Tuwunel Matrix homeserver configuration — server identity, database, authentication, registration policy, and admin access
- `durer-nginx-matrix-proxy`: Nginx reverse proxy for Matrix client API — routing `/_matrix/` requests to Tuwunel

### Modified Capabilities
<!-- No existing spec-level requirements change -->

## Impact

- **Files modified**: `modules/HOSTS/durer-server/configuration.nix` (add Tuwunel service + nginx proxy location)
- **Dependencies**: `matrix-tuwunel` package from nixpkgs
- **Storage**: RocksDB embedded database in `/var/lib/tuwunel/` (or service state dir)
- **Networking**: No new ports needed — Matrix API served through existing nginx on 443
- **Backup**: Tuwunel data directory should be included in backup strategy
