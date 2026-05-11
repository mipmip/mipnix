## 1. Secrets

- [x] 1.1 Generate PDS secrets and encrypt as `secrets/personal-data-server.env.age`
- [x] 1.2 Add `personal-data-server.env.age` entry in `secrets/secrets.nix` with publicKeys for `pim` and `durer`
- [x] 1.3 Add agenix secret declaration in durer config to decrypt `personal-data-server.env.age`

## 2. PDS Service

- [x] 2.1 Enable `services.bluesky-pds` with `PDS_HOSTNAME = "pimsnel.com"` and default settings
- [x] 2.2 Set `services.bluesky-pds.environmentFiles` to point to the agenix-decrypted secret path

## 3. Nginx Proxy

- [x] 3.1 Add nginx vhost for `pimsnel.com` with ACME, serving pimsnel-website as root, proxying `/xrpc/` and `/.well-known/atproto-did` to PDS on port 3000
- [x] 3.2 Configure WebSocket headers via `proxyWebsockets = true`
- [x] 3.3 Set `client_max_body_size` to 100m on the PDS proxy location

## 4. Verification

- [x] 4.1 Verify `nixos-rebuild` succeeds with the new configuration (dry run or build)
- [x] 4.2 Document account creation steps using `pdsadmin`

### Account Creation Steps

After deploying, create your account on durer:

```bash
sudo pdsadmin account create
```

Follow the prompts to set your handle (`pimsnel.com`), email, and password. Then log in with any Bluesky client using `pimsnel.com` as the hosting provider.
