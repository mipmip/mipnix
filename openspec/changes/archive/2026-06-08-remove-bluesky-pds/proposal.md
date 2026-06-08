## Why

The Bluesky PDS (Personal Data Server) running on `durer` is not important enough to keep.
It was never actually used — no account, handle, or atproto identity was created on it — so
removing it has no external or data consequences. This is straightforward cleanup to reduce
durer's footprint and attack surface.

Related task: [mipnix-tvd5](.beans/mipnix-tvd5--remove-bluesky-pds-not-important-enough-for-now.md)

## What Changes

- Remove the `services.bluesky-pds` configuration from `durer`.
- Remove the PDS secret: the `age.secrets."personal-data-server-env"` block, the
  `secrets/secrets.nix` registry entry, and the encrypted `personal-data-server.env.age`
  file (full delete — clean slate, not kept dormant).
- Remove the two atproto proxy locations (`/xrpc/` and `/.well-known/atproto-did`) from the
  shared `pimsnel.com` nginx vhost — **keeping the vhost itself, its ACME/SSL, and the
  website root**, which serve other purposes.
- At deploy time, clean up any orphaned PDS state directory left on durer (NixOS stops the
  service but does not garbage-collect its `/var/lib` data).

## Capabilities

### Modified Capabilities

- `durer-nginx-pimsnel`: The `pimsnel.com` vhost continues to serve the website over ACME
  HTTPS, but no longer proxies the atproto/PDS endpoints (`/xrpc/`,
  `/.well-known/atproto-did`).

### Removed Capabilities

- `bluesky-pds`: The Personal Data Server on `durer` is removed entirely (service, secret,
  and atproto endpoints).

## Impact

- `modules/HOSTS/durer-server/configuration.nix`: remove the `services.bluesky-pds` block,
  the `age.secrets."personal-data-server-env"` block, and the two PDS `locations` under the
  `pimsnel.com` vhost (leave the vhost, `root`, `enableACME`, `forceSSL` intact).
- `secrets/secrets.nix`: remove the `"personal-data-server.env.age"` publicKeys line.
- `secrets/personal-data-server.env.age`: delete the file.
- durer (deploy-time): remove the orphaned PDS state directory (path determined on the
  server).
- `services.bluesky-pds` is an upstream nixpkgs service — no local module to delete.
- Bookkeeping (out of scope for the code change, noted for follow-up): the original
  `bluesky-pds-on-durer` add-change is still active/unarchived; archive it separately so
  history reads "added, then removed."
