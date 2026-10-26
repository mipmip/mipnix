## Why

Studio MINT is becoming three sites instead of one, and durer serves one.

The point of the exercise is `v2.studio-mint.shop` and the apex with its `www`.
The shop on the apex is an archived version: it runs with `maintenanceMode =
true` and is not where the work is any more. It moves to `v1.studio-mint.shop`
to free the apex, not because it needs a new home.

Its repository was renamed from `mintglasinlood/voorzetramenshop` to
`mintglasinlood/v1.studio-mint.shop`, and `flake.nix` still names the old one.
That is not yet broken, because GitHub redirects after a rename and the old URL
still resolves to the same revision, but the input is lying about where the
code lives.

Two private repositories were added, `v2.studio-mint.shop` and
`studio-mint.shop`. Both hold static HTML today and both will stop being static
later. Their contents moved around while this change was being applied and
settled as: the apex is a "binnenkort" holding page (9 files, favicons and a
`site.webmanifest` it loads from an absolute path), and v2 is the real site in
progress (59 files across `ds/` and `img/`, with a collection, a configurator,
an FAQ and the legal pages).

DNS is already in place for all four names, all pointing at durer. nginx is
not. Only the apex has a vhost, so the other three answer on the default server
with the wrong certificate:

```
studio-mint.shop        http=200
www.studio-mint.shop    SSL: no alternative certificate subject name matches
v1.studio-mint.shop     SSL: no alternative certificate subject name matches
v2.studio-mint.shop     SSL: no alternative certificate subject name matches
```

So `www` is not an existing thing to repoint. It has to be created.

## What Changes

- Rename the flake input `voorzetramenshop` to `studio-mint-v1` and point it at
  `git+ssh://git@github.com/mintglasinlood/v1.studio-mint.shop.git`. Update the
  two places that consume it: `configuration.nix:243` and the comment in
  `RUNME.d/deploy.sh`, which tells the maintainer to run
  `nix flake update voorzetramenshop` before deploying.
- Set `services.voorzetramenshop.domain = "v1.studio-mint.shop"`. The shop's own
  module builds its vhost from that option, so the shop's vhost moves with it
  and the apex is freed.
- Add `studio-mint-apex` and `studio-mint-v2` as `flake = false` inputs, each
  rendered by a `runCommand` that copies the repository and drops `README.md`,
  following the `pimsnel-website` pattern in `flake.nix:274`.
- Add three vhosts on durer: `studio-mint.shop` serving the apex package,
  `v2.studio-mint.shop` serving the v2 package, and `www.studio-mint.shop` as a
  301 to the apex via `globalRedirect`.
- Leave the service option name, the database name and the backup dataset
  (`services.voorzetramenshop`, database `voorzetramenshop`,
  `durer-voorzetramenshop`) untouched. The repository was renamed, the module
  inside it was not.

## Capabilities

### New Capabilities

- `studio-mint-static-hosting`: the two static Studio MINT sites on durer, how
  a repository without a flake becomes a served directory, the www redirect,
  and how a content change reaches production.

### Modified Capabilities

- `voorzetramenshop-hosting`: five requirements name the old repository URL, the
  old input name, or the old domain. Two of them are already stale: the spec
  still says `domain = "mintshop.nuremberg.pimsnel.com"` and `AUTH_URL =
  https://mintshop.nuremberg.pimsnel.com`, while the configuration has said
  `studio-mint.shop` since the apex move. This change brings all five to
  `v1.studio-mint.shop`.

## Impact

- `flake.nix`: one input renamed and repointed, two inputs added, two
  `runCommand` packages added.
- `flake.lock`: the shop moves from `5ed68ec` to `a498843` as a side effect of
  the rename, because a re-added input resolves fresh against `HEAD` and the
  lock had fallen behind. Same version (0.4.0, the changes sit under
  `[Unreleased]`): one user-facing fix (after a magic-link login you land on the
  account page instead of back on the login screen), three development and
  bookkeeping commits, and the build fix below. Taken deliberately rather than
  pinned back, because pinning back does not avoid the build fix anyway.
- One commit in `mintglasinlood/v1.studio-mint.shop` (`a498843`), outside this
  repository. The shop could not be built at all: its `fonts` fixed-output
  derivation captures the Google Fonts CSS that `next/font/google` would
  otherwise fetch at build time, and Google now returns a different response
  than when that hash was recorded, so every build failed on a hash mismatch.
  Both candidate revisions carried the same stale hash (`nix/` is identical
  between them), so this blocked the deploy regardless of which one was pinned,
  and blocked every other durer deploy too. The hash was refreshed and the
  capture verified deterministic across two consecutive builds.
- `modules/HOSTS/durer-server/configuration.nix`: the shop's `domain`, the
  import on line 243, and three new vhosts.
- `RUNME.d/deploy.sh`: the input name in the version-bump comment.
- No change to `secrets/`. The maintainer has already repointed `AUTH_URL` in
  `voorzetramenshop-env.age`, and `AUTH_TRUST_HOST = "true"` on
  `configuration.nix:160` makes Auth.js follow the forwarded Host header
  regardless.

Constraints:

- Three new certificates are issued on first activation: `v1`, `v2` and `www`.
  The apex certificate already exists and is reused, because ACME state is
  keyed on the hostname and not on what the vhost serves. Well inside Let's
  Encrypt's limits, but it does mean nothing answers on `v1.studio-mint.shop`
  until the HTTP-01 challenge completes. What is unavailable in that window is
  an archived shop in maintenance mode, so the window costs little; the names
  this change exists for, the apex and `www`, are new and have nothing to lose.
- The apex holding page sets `<meta name="robots" content="noindex">` and the
  v2 site does not, while both are publicly reachable. So the site that is not
  meant to be found yet is the one search engines may crawl, and it carries the
  same copy the apex will eventually serve. Not this change's call to make, but
  worth deciding before v2 gets linked anywhere.
- Both static inputs are private repositories over SSH. The machine that runs
  the deploy needs the key, durer does not, because deploy-rs builds locally and
  pushes the closure. Already true for the shop.
- A content change in either static repository needs `nix flake update
  <input>` in mipnix before the deploy. Having no flake in those repositories
  does not change that; the lock records a revision either way.
