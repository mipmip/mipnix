# Tasks

## 1. DNS in nivis

- [x] 1.1 Add an A record `v3.studio-mint.shop` → `178.104.252.76` (TTL 3600) to `nivis/stack/010_route53/zones/studio-mint.shop.nix` in `wasnel-awsaccount-104144963194-main`; verify `AWS_PROFILE=wasnel ./nivis/stackctl production 010_route53 plan` shows exactly one record to add
- [x] 1.2 Apply it with `./nivis/stackctl production 010_route53 apply` and commit in that repo; verify `dig +short v3.studio-mint.shop` returns `178.104.252.76`

## 2. Flake input

- [x] 2.1 Add input `studio-mint-v3` (`git+ssh://git@github.com/mintglasinlood/v3.studio-mint.shop.git`, `inputs.nixpkgs.follows = "nixpkgs"`) to `flake.nix` and run `nix flake update studio-mint-v3` as the user; verify `nix flake show` on the input lists `nixosModules.default` and `packages.x86_64-linux.studio-mint-v3`
- [x] 2.2 Name `studio-mint-v3` in the private-input comment of `RUNME.d/deploy.sh`; verify the file still passes `bash -n`

## 3. Secret

- [x] 3.1 Add `"studio-mint-v3-env.age".publicKeys = [ pim durer ];` to `secrets/secrets.nix` and create the secret with a fresh `AUTH_SECRET` (`openssl rand -base64 32`), `AUTH_URL=https://v3.studio-mint.shop`, v1's current `EMAIL_SERVER` and `EMAIL_FROM="Studio MINT <noreply@studio-mint.shop>"`; verify by decrypting that the four keys are present, `DATABASE_URL` and `MAINTENANCE_MODE` are absent, and `AUTH_SECRET` differs from v1's

## 4. durer configuration

- [x] 4.1 In `modules/HOSTS/durer-server/configuration.nix`, declare `age.secrets."studio-mint-v3-env"`, enable `services.studio-mint-v3` (domain `v3.studio-mint.shop`, port 3003, `maintenanceMode = true`, `environmentFile` from the secret) and import `inputs.studio-mint-v3.nixosModules.default`; verify `nix eval .#nixosConfigurations.durer.config.services.studio-mint-v3.port` prints 3003 and the v1 options evaluate unchanged
- [x] 4.2 Add the `durer-studio-mint-v3` dataset to `datasetsFor` (pg_dump of `studio_mint_v3`, v1's retention); verify `nix eval .#resticRepos.durer` lists `durer-studio-mint-v3`
- [x] 4.3 Build the closure on lego2 with `nix build .#nixosConfigurations.durer.config.system.build.toplevel`; verify it builds and contains the v3 package

## 5. Deploy and verify on durer

- [ ] 5.1 Deploy with `rme deploy_remote durer`; verify `studio-mint-v3-migrate.service` finished and `studio-mint-v3.service` is active, and that `curl -sI https://v3.studio-mint.shop/` returns 503 and `/inloggen` returns 200 with a valid certificate
- [x] 5.2 Check that v1 and the static sites are untouched; verify `v1.studio-mint.shop`, `studio-mint.shop` and `v2.studio-mint.shop` answer as before
- [x] 5.3 Create the first admin with the SQL from design.md and log in by magic link; verify you land in `/admin`, and that the development credentials `admin@studio-mint.shop` / `mint-dev-admin` are refused
- [x] 5.4 Start the `durer-studio-mint-v3` backup once by hand; verify a snapshot exists in `/ResticBackups/durer-studio-mint-v3` and the dump file is gone afterwards

## Workflow follow-up

- Archive this change in mipnix and set bean `mipnix-6b73` to completed with the archive link.
- In v3, set bean `v3.studio-mint.shop-l1lh` to completed with a link to this change.
