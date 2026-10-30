# Proposal

Bean: [mipnix-6b73](../../../.beans/mipnix-6b73--studio-mint-v3-staging-op-durer.md)
(from the v3 epic `v3.studio-mint.shop-l1lh`, "Staging op durer")

## Why

The v3 webshop now ships a Nix package and a NixOS module
(`services.studio-mint-v3`) with automatic migrations, but it runs nowhere.
Every later v3 epic (configurator, Mollie, mail) needs a real host to test on.
durer already hosts v1 and the static sites, so v3 goes there as staging,
closed to visitors, next to v1.

## What Changes

- New private flake input `studio-mint-v3` for
  `mintglasinlood/v3.studio-mint.shop`, following mipnix's nixpkgs.
- durer imports `inputs.studio-mint-v3.nixosModules.default` and enables
  `services.studio-mint-v3` on `v3.studio-mint.shop`, port 3003, maintenance
  mode on, with the flake's own package.
- New agenix secret `studio-mint-v3-env.age` for `[ pim durer ]` holding
  `AUTH_SECRET`, `AUTH_URL` and the mail settings.
- New restic dataset `durer-studio-mint-v3` with a `pg_dump` of the
  `studio_mint_v3` database.
- DNS: an A record `v3.studio-mint.shop` in the nivis Route 53 zone
  (repository `wasnel-awsaccount-104144963194-main`), applied before the
  deploy so ACME can issue the certificate.
- `RUNME.d/deploy.sh` names `studio-mint-v3` among the private inputs.

Out of scope: the uploads directory in the backup (arrives with the v3 uploads
epic), the Mollie test key (with the Mollie epic), SES credentials (with the
mail epic). Until then the secret reuses the mail relay v1 uses.

## Capabilities

### New Capabilities

- `studio-mint-v3-hosting`: how v3 runs on durer next to v1: input, service,
  secret, DNS, backup and the first admin account on staging.

### Modified Capabilities

None. `voorzetramenshop-hosting` (v1) and `studio-mint-static-hosting` keep
their requirements; v3 only has to leave them untouched, which the new spec
states.

## Impact

- `flake.nix`, `flake.lock`, `secrets/secrets.nix`, a new
  `secrets/studio-mint-v3-env.age`, `modules/HOSTS/durer-server/configuration.nix`,
  `RUNME.d/deploy.sh`.
- nivis: `nivis/stack/010_route53/zones/studio-mint.shop.nix` plus an apply of
  the `010_route53` domain.
- durer: one more PostgreSQL database and user on the existing PostgreSQL 17,
  one more nginx vhost and certificate.
