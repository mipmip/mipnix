## Why

The voorzetramenshop webshop needs a production home. It ships its own NixOS module and (as of the merged `nix-package-and-deploy-migrations` change) a runnable package + automatic migration step, so durer — which already fronts `pimsnel.com`/`nuremberg.pimsnel.com` with nginx + ACME — is the natural host. Deploying it as a private flake input lets new versions ship with a single `nix flake update voorzetramenshop` + deploy, with `flake.lock` as the audit trail and rollback point.

But durer is a small VM (**30 GB disk, ~15 GB free**) and the shop's Next.js **build** does not fit: `pnpm`'s full `node_modules`, the webpack/turbopack compile, and the nixpkgs build-input chain are several GB of build-time garbage that overflow the disk — even though the *runtime closure* is only ~322 MiB (measured: 42.6 MiB shop bundle + 245.6 MiB `nodejs_22`). So the shop cannot be built **on** durer. This change therefore also establishes the deployment model: **build on lego2** (882 GB disk, native x86_64-linux), then **copy only the closure to durer** via **deploy-rs**, with magic rollback for a box reachable only over Nebula. Linked task: `.beans/mipnix-nbpu--configure-durer-with-a-smart-deployment-tool.md` (epic `.beans/mipnix-rxxc--mintglas-deployment.md`).

## What Changes

- Add `voorzetramenshop` as a **private** flake input (`git+ssh://git@github.com/mintglasinlood/voorzetramenshop.git`) in `flake.nix`, with `inputs.nixpkgs.follows = "nixpkgs"` to keep the closure aligned with durer's nixos-26.05.
- Import `inputs.voorzetramenshop.nixosModules.default` into the durer host module and enable `services.voorzetramenshop` with `domain = "mintshop.nuremberg.pimsnel.com"`, `port = 3001` (3000 is taken by `services.bluesky-pds`), `maintenanceMode = true` for launch, and `environmentFile` sourced from agenix. The `package` option is left to its default (the flake's `voorzetramenshop` package).
- Add an agenix secret `voorzetramenshop-env` (`secrets/voorzetramenshop-env.age`, `publicKeys = [ pim durer ]`) holding `AUTH_SECRET`, `AUTH_URL`, `MOLLIE_API_KEY`, `EMAIL_SERVER` (AWS SES SMTP), and `EMAIL_FROM`. `DATABASE_URL` and `MAINTENANCE_MODE` are owned by the module and excluded.
- Compose with durer's existing nginx + `security.acme` (the module's `enableACME`/`forceSSL`/email defaults yield via `lib.mkDefault`; the new vhost key is distinct from existing hosts).
- Add **deploy-rs** as a flake input (`inputs.nixpkgs.follows = "nixpkgs"`) and a top-level `flake.deploy.nodes.durer` (via flake-parts' `flake.deploy = { … }` escape hatch) targeting `self.nixosConfigurations.durer` at the Nebula IP `192.168.100.12`, activating over durer's passwordless sudo with magic rollback.
- Add `nix.settings.trusted-users = [ "root" "pim" ]` to durer so deploy-rs's `ssh-ng` push of a lego2-built (unsigned) closure is accepted (verified-live blocker).
- Add a GC policy on durer (`boot.loader.grub.configurationLimit` and/or a `nix.gc` timer) to bound the disk while preserving rollback generations.
- Add a `deploy_remote <host>` wrapper in `RUNME.d/` (run from the build host, takes the target as an argument) that reuses `check_untracked`/`git_sync_machine` and drives deploy-rs.
- Document the build-on-lego2 deploy/rollback workflow and a pre-launch checklist (DNS, SES out of sandbox, derived SMTP password, `nix flake show` output confirmation).

## Capabilities

### New Capabilities
- `voorzetramenshop-hosting`: Hosting the voorzetramenshop webshop on durer — private flake input wiring, NixOS module import + service configuration, agenix-backed environment secret, nginx/ACME composition, the **deploy-rs build-on-lego2 deployment model** (deploy-rs input + `flake.deploy.nodes.durer` + `trusted-users` fix + durer GC policy + `deploy_remote` RUNME.d wrapper), and the version-bump deploy/rollback workflow.

### Modified Capabilities
<!-- None. The module sets security.acme/nginx defaults via lib.mkDefault, so durer's existing durer-nginx-acme requirements are unaffected. -->

## Impact

- **Files modified**: `flake.nix` (`voorzetramenshop` + `deploy-rs` inputs), `modules/HOSTS/durer-server/configuration.nix` (module import + `services.voorzetramenshop` + `age.secrets."voorzetramenshop-env"` + `nix.settings.trusted-users` + GC policy), `secrets/secrets.nix` (new recipient entry).
- **New files**: `secrets/voorzetramenshop-env.age` (created via `agenix -e`; already authored by the user); a module defining `flake.deploy.nodes.durer`; `RUNME.d/deploy.sh` (the `deploy_remote` wrapper).
- **New DNS**: `mintshop.nuremberg.pimsnel.com` → durer (covered by the `*.nuremberg.pimsnel.com` wildcard already added).
- **New service surface**: PostgreSQL db/user `voorzetramenshop`, a `prisma migrate deploy` oneshot, a hardened DynamicUser systemd service on `127.0.0.1:3001`, and an nginx vhost with its own ACME cert.
- **Deployment model change**: deploys now run **from lego2** (`rme deploy_remote durer`), not as `sudo nixos-rebuild` **on** durer. durer never builds the shop; only the ~322 MiB runtime closure is copied.
- **External dependency**: AWS SES (SMTP send) must be reachable and out of sandbox for magic-link login to work — magic-link is the only auth path.
- **Upstream dependency**: relies on `voorzetramenshop`'s merged `nix-package-and-deploy-migrations` outputs (`packages.<system>.voorzetramenshop`, migrate oneshot); confirm via `nix flake show` before the deploy.
- **No new firewall ports**: nginx (80/443) fronts the service; 3001 is loopback-only. deploy-rs reaches durer over the existing SSH (22) on the Nebula mesh.
