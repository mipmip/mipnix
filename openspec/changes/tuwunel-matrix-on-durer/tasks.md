## 1. Tuwunel Service

- [x] 1.1 Enable `services.matrix-tuwunel` with `server_name = "nuremberg.pimsnel.com"`
- [x] 1.2 Set `allow_registration = false`, `allow_federation = false`, `allow_encryption = true`, `trusted_servers = []`
- [x] 1.3 Configure listening on localhost port 6167

## 2. Nginx Proxy

- [x] 2.1 Add `/_matrix/` location block to existing nginx vhost proxying to `http://localhost:6167`
- [x] 2.2 Add `/.well-known/matrix/server` location returning `{"m.server": "nuremberg.pimsnel.com:443"}`
- [x] 2.3 Add `/.well-known/matrix/client` location returning homeserver base URL with CORS headers
- [x] 2.4 Set `client_max_body_size` to 20M for the Matrix proxy location

## 3. Verification

- [x] 3.1 Verify `nixos-rebuild` succeeds with the new configuration (dry run or build)
- [x] 3.2 Document initial account creation steps (Tuwunel CLI)

### Account Creation Steps

After deploying, create your admin account on durer:

```bash
# SSH into durer, then run:
sudo -u tuwunel tuwunel --config /etc/tuwunel/tuwunel.toml create-user --username pim --password <your-password> --admin
```

If the CLI syntax differs, check:
```bash
tuwunel --help
```

Or use the admin API locally:
```bash
# Register via admin API (from durer)
curl -X POST http://localhost:6167/_matrix/client/v3/register \
  -H "Content-Type: application/json" \
  -d '{"username":"pim","password":"<your-password>","auth":{"type":"m.login.dummy"}}'
```

Note: The admin API registration may work even with `allow_registration = false` when called from localhost, depending on Tuwunel's configuration. If not, temporarily enable registration, create the account, then disable it again.
