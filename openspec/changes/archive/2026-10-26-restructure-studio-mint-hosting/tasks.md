## 1. Follow the repo rename

- [x] 1.1 Rename the `voorzetramenshop` input in `flake.nix` to `studio-mint-v1` and repoint it at `git+ssh://git@github.com/mintglasinlood/v1.studio-mint.shop.git`, keeping `inputs.nixpkgs.follows = "nixpkgs"`
- [x] 1.2 Update the import on `modules/HOSTS/durer-server/configuration.nix:243` to `inputs.studio-mint-v1.nixosModules.default`
- [x] 1.3 Update the version-bump comment in `RUNME.d/deploy.sh` to name `studio-mint-v1`, so the documented command resolves
- [x] 1.4 Run `nix flake lock` and verify the lock records the new URL, and that only this input's node changed
- [x] 1.5 Verify `nix flake show` on the locked input still exposes `nixosModules.default` and `packages.<system>.voorzetramenshop`, since the module inside the repo was not renamed

## 2. Move the shop off the apex

- [x] 2.1 Set `services.voorzetramenshop.domain = "v1.studio-mint.shop"` in `modules/HOSTS/durer-server/configuration.nix`
- [x] 2.2 Verify the evaluated vhost list for durer now contains `v1.studio-mint.shop` and no longer contains `studio-mint.shop` from the module
- [x] 2.3 Verify the shop option, the `voorzetramenshop` database and the `durer-voorzetramenshop` backup dataset are untouched

## 3. The static sites

- [x] 3.1 Add `studio-mint-apex` and `studio-mint-v2` as `flake = false` inputs pointing at `mintglasinlood/studio-mint.shop` and `mintglasinlood/v2.studio-mint.shop`
- [x] 3.2 Add a `runCommand` package per site in `flake.nix`, following the `pimsnel-website` pattern, each copying the repository and removing `README.md`
- [x] 3.3 Verify each package builds and that `index.html` sits at its root with no `README.md` beside it
- [x] 3.4 Verify the apex package carries `site.webmanifest` and all seven icon files, which the page loads by absolute path

## 4. The vhosts

- [x] 4.1 Add a `studio-mint.shop` vhost on durer with `enableACME`, `forceSSL` and `root` set to the apex package
- [x] 4.2 Add a `v2.studio-mint.shop` vhost on durer with `enableACME`, `forceSSL` and `root` set to the v2 package
- [x] 4.3 Add a `www.studio-mint.shop` vhost with `enableACME`, `forceSSL` and `globalRedirect = "studio-mint.shop"`
- [x] 4.4 Verify the evaluated vhost list for durer is exactly the five pre-existing non-shop names plus `studio-mint.shop`, `www.studio-mint.shop`, `v1.studio-mint.shop` and `v2.studio-mint.shop`
- [x] 4.5 Verify the durer closure builds before deploying anything

## 5. Deploy

- [x] 5.1 Re-check that all four names still resolve to durer, since a failed HTTP-01 challenge is the one thing that takes the shop down
- [x] 5.2 Deploy with `rme deploy_remote durer` at a moment when a few minutes of shop downtime is acceptable
- [x] 5.3 Verify certificates were issued for `v1`, `v2` and `www`, and that the apex certificate was reused rather than reissued
- [x] 5.4 Verify `https://v1.studio-mint.shop/` serves the shop, in maintenance mode as configured
- [x] 5.5 Verify `https://studio-mint.shop/` serves the holding page, including `/site.webmanifest` and the favicons
- [x] 5.6 Verify `https://v2.studio-mint.shop/` serves the v2 site, including at least one asset under `ds/` and one under `img/` so the subdirectories are confirmed served
- [x] 5.7 Verify `https://www.studio-mint.shop/` answers 301 to `https://studio-mint.shop/` with a valid certificate
- [x] 5.8 Verify `https://studio-mint.shop/README.md` is 404, so the `flake = false` store path is not leaking repository files

## 6. What it must not affect

- [x] 6.1 Verify `https://pimsnel.com/`, `https://nuremberg.pimsnel.com/`, `https://taste.pimsnel.com/` and `https://umami.pimsnel.com/` still answer as before
- [x] 6.2 Verify a shop login still redirects to `v1.studio-mint.shop`, confirming `AUTH_TRUST_HOST` covers the `AUTH_URL` in the secret
- [x] 6.3 Verify the `durer-voorzetramenshop` restic dataset still dumps and backs up after the deploy

## 7. Specs and follow-ups

- [x] 7.1 Note that the `voorzetramenshop-hosting` capability keeps its name, because `services.voorzetramenshop` does
- [x] 7.2 Record a bean for removing the apex page's `robots: noindex` and its "binnenkort" copy once the real apex site exists
