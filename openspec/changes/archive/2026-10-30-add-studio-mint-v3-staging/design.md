# Design

## Context

See proposal.md for motivation. v1 sets the pattern (spec
`voorzetramenshop-hosting`): private input, module import, agenix env file,
build on lego2, `rme deploy_remote durer`. v3 differs in four ways that matter
here:

- v3's package builds with nixpkgs' default pnpm (11), so durer needs no
  `callPackage` override and no insecure-package exception, unlike v1.
- v3's module runs the app as the system user `studio_mint_v3`, not as a
  DynamicUser, and sets `AUTH_TRUST_HOST` itself.
- v3's module has a `tls` option (default `true`); durer keeps the default.
- v3 has no admin-creation tool, and its development seed admin has a
  published password.

## Goals / Non-Goals

**Goals:**
- A staging v3 reachable over HTTPS, closed by maintenance mode, with its
  database backed up.
- A first admin login without putting a known password on a public host.

**Non-Goals:**
- Uploads backup, Mollie, SES: later v3 epics extend this spec.
- Moving v3 to the apex: that is the v3 launch epic.

## Decisions

### Use the flake's package and module as is

`services.studio-mint-v3.package` is left to the module's default
(`inputs.studio-mint-v3.packages.x86_64-linux.studio-mint-v3`). Because the
input follows mipnix's nixpkgs, the closure shares the store paths of the
host. Alternative: `callPackage` its `nix/package.nix` like v1. Not needed,
since there is no insecure pnpm in the way.

### DNS first, in nivis, then deploy

The record goes into `nivis/stack/010_route53/zones/studio-mint.shop.nix`
next to `v1` and `v2`, applied with
`./nivis/stackctl production 010_route53 apply`. Only after it resolves does
the deploy enable the vhost; otherwise ACME fails its first challenge and
durer retries on a backoff. Alternative: a wildcard record for
`*.studio-mint.shop`. Rejected: every name stays explicit, as the zone does
now.

### First admin via SQL and magic link

After the first deploy, the maintainer runs on durer:

```bash
sudo -u studio_mint_v3 psql studio_mint_v3 -c \
  "INSERT INTO \"User\" (id, email, name, role, \"updatedAt\")
   VALUES (gen_random_uuid()::text, 'pim@…', 'Pim', 'ADMIN', now())"
```

and logs in with a magic link. No password ever exists for this account until
the admin sets one later (an account epic in v3). Alternative: run the v3
seed. Rejected: its password is in the v3 README.

### Mail for now: the relay v1 already uses

`EMAIL_SERVER` in the new secret copies v1's current value, with
`EMAIL_FROM = Studio MINT <noreply@studio-mint.shop>`. The SES epic in v3
replaces it. A magic link that lands in spam still works for the maintainer.

### Backup dataset mirrors v1's

`durer-studio-mint-v3` in `datasetsFor`, with `runuser -u postgres --
pg_dump studio_mint_v3` and the same retention as v1
(`24 hourly, 14 daily, 6 monthly`). The repository is created by the existing
backup role on its first run.

## Risks / Trade-offs

- [Two Next.js servers and their builds on durer] → builds happen on lego2;
  durer only holds two closures. Memory of a second idle Node process is
  acceptable on durer.
- [v1 mail relay lands in spam (v1 bean 3yuc)] → only the maintainer uses
  mail on staging until the SES epic.
- [The VM test in v3's flake does not run here] → durer's eval only builds
  the package; the v3 gate already proved the module.

## Migration Plan

1. nivis: add and apply the A record; check `dig +short v3.studio-mint.shop`.
2. mipnix: input, secret, service, backup; `nix flake update studio-mint-v3`
   as the user; `rme deploy_remote durer` on lego2.
3. On durer: create the first admin, log in by magic link.

Rollback: revert the commit (or `nixos-rebuild switch --rollback` on durer).
The `studio_mint_v3` database stays and can be dropped by hand if v3 is
abandoned.
