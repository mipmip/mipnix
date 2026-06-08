## 1. Remove PDS config from durer

- [x] 1.1 Removed the `services.bluesky-pds = { ... }` block from `modules/HOSTS/durer-server/configuration.nix`
- [x] 1.2 Removed the `age.secrets."personal-data-server-env" = { ... }` block from the same file
- [x] 1.3 Removed only the two PDS proxy locations (`/xrpc/`, `/.well-known/atproto-did`) from the `pimsnel.com` vhost; kept the vhost with `root` (website), `enableACME`, and `forceSSL`. (`config` arg is now unused but harmless in a nixos module signature.)

## 2. Remove the secret

- [x] 2.1 Removed the `"personal-data-server.env.age".publicKeys` line from `secrets/secrets.nix`
- [x] 2.2 Deleted `secrets/personal-data-server.env.age` (git shows it as removed)

## 3. Build and verify config

- [x] 3.1 `nix build .#nixosConfigurations.durer.config.system.build.toplevel` succeeds — no dangling references to the removed secret/service.
- [x] 3.2 Verified: `pimsnel.com` vhost `root` = `pimsnel-website` (website intact), its `locations` = `{ }` (no atproto/xrpc), and `services.bluesky-pds.enable` = `false`.

## 4. Deploy and clean up

- [x] 4.1 Deployed durer (`up_machine`).
- [x] 4.2 Confirmed `https://pimsnel.com/` still serves the website and the `bluesky-pds` service is gone.
- [x] 4.3 Removed the orphaned PDS state directory on durer.
