## Context

See proposal.md for motivation. The facts that decided the approach, all read
off the repository and the live host:

- `modules/HOSTS/durer-server/configuration.nix:146` sets
  `services.voorzetramenshop` with `domain = "studio-mint.shop"`, `port = 3001`
  and `maintenanceMode = true`.
- The shop's module (`nix/module.nix:172` in its own repository) creates exactly
  one vhost, `virtualHosts.${cfg.domain}`, with `enableACME` and `forceSSL`. It
  has no `serverAliases` and no www handling, which is why the apex is the only
  Studio MINT name nginx knows.
- durer's vhosts today: `nuremberg.pimsnel.com`, `pimsnel.com`,
  `secondbrain.pimsnel.com`, `studio-mint.shop`, `taste.pimsnel.com`,
  `umami.pimsnel.com`.
- All four Studio MINT names resolve to `178.104.252.76`, which is durer.
- `flake.nix:274` already shows the static-site pattern: a `runCommand` that
  copies a directory, consumed as `root = inputs.self.packages.<system>.<name>`
  on `configuration.nix:120`.
- `RUNME.d/deploy.sh` is the deploy path (`rme deploy_remote durer`), and its
  comment block names `nix flake update voorzetramenshop` as a load-bearing
  first step.
- `v2.studio-mint.shop` contains `README.md` and a four-byte `index.html` whose
  content is `...`. `studio-mint.shop` contains `README.md`, `index.html`,
  `site.webmanifest` and seven icon files.

## Goals / Non-Goals

**Goals:**

- The shop answers on `v1.studio-mint.shop` and nowhere else.
- The apex serves the new landing page, www redirects to it.
- `v2.studio-mint.shop` serves its own content from its own vhost.
- The flake input names where the code lives.
- Updating a static site is one documented sequence.

**Non-Goals:**

- Giving either static repository its own flake. Not needed while the content
  is plain HTML, and it would not shorten the deploy either way.
- Renaming `services.voorzetramenshop`, the `voorzetramenshop` database, or the
  `durer-voorzetramenshop` backup dataset. The repository was renamed; the
  module, the schema and the dumps were not.
- Renaming the `voorzetramenshop-hosting` capability. The option it describes
  still carries that name.
- Anything about what v2 will become.
- Removing the apex page's `noindex`.

## Decisions

### `flake = false` plus `runCommand`, not a flake per repository

A repository of static HTML needs nothing from a flake. As a `flake = false`
input it arrives as a bare store path, and a `runCommand` turns it into a
served directory:

```nix
packages.studio-mint-apex = pkgs.runCommand "studio-mint-apex" { } ''
  mkdir -p $out
  cp -r ${inputs.studio-mint-apex}/* $out/
  rm -f $out/README.md
'';
```

The `rm -f $out/README.md` matters. With `flake = false` the whole repository
becomes the store path, so without it `https://studio-mint.shop/README.md`
would be served.

Rejected: putting the HTML in `packages/` inside mipnix, the way
`pimsnel-website` does. That makes a content change one commit instead of two
repositories plus a lock bump, which for a four-byte placeholder is the
cheaper arrangement. But both sites are stated to become real applications, and
moving them out of mipnix later is more work than leaving them where they are.

Rejected: a flake in each repository now. It buys nothing today. The moment
either grows a build step, or wants to ship its own NixOS module the way v1
does, that is when it earns one.

### The shop's vhost moves by changing one option

`domain` is the only thing that decides where the shop answers, because its
module derives the vhost from it. So the move is a one-line change, and the
apex becomes free in the same evaluation. Nothing in mipnix has to delete the
old vhost.

The consequence is that the apex vhost and the shop vhost are never both
defined for the same name, so there is no merge conflict in
`services.nginx.virtualHosts` to reason about.

### www is a redirect, not a second copy

`globalRedirect` emits a 301 to the apex. One page to maintain, and the
canonical name stays `studio-mint.shop`, which is what the page's own metadata
assumes. It still needs `enableACME` and `forceSSL`, because a redirect over
HTTPS needs a certificate for the name being redirected from.

### Certificates are the risky part of the first deploy

Activation issues three new certificates. ACME state is keyed on the hostname,
so the existing apex certificate survives the change of root untouched, but
`v1`, `v2` and `www` each need an HTTP-01 challenge to complete before their
vhost serves anything.

That makes the first deploy the one moment the shop is unreachable: the old
name stops serving it the instant the new generation activates, and the new
name only starts once its challenge succeeds. DNS is already correct, which is
the precondition that usually makes this fail, so the window should be short.

How much that window costs is small. The shop is an archived version running
with `maintenanceMode = true`, so what goes dark is a maintenance page. The
apex and `www`, which this change exists for, are not serving anything worth
keeping either: the apex shows the shop's maintenance page today and `www` an
outright certificate error.

Rejected: adding `v1.studio-mint.shop` as a `serverAliases` on the apex first,
deploying, and moving `domain` in a second deploy. It would shorten the window,
but the shop's module owns its vhost and does not expose aliases, so this would
mean defining a second vhost for a name the module is about to claim, and then
removing it. Two deploys and a conflicting definition to buy a few minutes.

## Risks / Trade-offs

- If the HTTP-01 challenge for `v1.studio-mint.shop` fails, that name stays
  down until it succeeds. Mitigation: DNS is verified correct before deploying,
  and deploy-rs magic rollback returns durer to the previous generation if
  activation leaves it unreachable. Note that an ACME failure does not
  necessarily make durer unreachable, so rollback may not trigger by itself.
  The same failure on the apex or `www` matters more than on `v1`, since those
  are the names this change is for.
- Serving two sites from `flake = false` inputs means a content typo is a lock
  bump and a deploy away from production, with no build step to catch anything.
  That is the nature of static HTML and the reason it is cheap.
- The old repository URL still works through GitHub's redirect, so nothing
  forces this rename. It will stop being true if the name is ever reused.

### The shop's font capture is a recurring liability

Found while building: the shop pins a hash over a Google Fonts response, which
Google changed, so the package stopped building entirely. Not caused by this
change, and not avoidable by pinning the revision back, because both candidate
revisions carry the same hash.

It is worth naming the pattern rather than only the incident. The same
repository already recorded a 0.3.1 release whose sole content was refreshing a
`pnpmDeps` hash that had gone stale, for the same structural reason: a
fixed-output derivation over something a third party can change underneath it.
The fonts capture will do this again. Making it not recur means vendoring the
font files into the repository instead of capturing them at build time, which
is a change to the shop and not to its hosting.

For an archived shop the cheap answer is to refresh the hash when it bites. If
v1 is ever revived, vendoring is the better answer.

## Open Questions

- The apex page carries `robots: noindex` and a "binnenkort" message. Nothing
  here changes it, and nothing tracks when it should go. Worth a bean once the
  real apex site exists.
