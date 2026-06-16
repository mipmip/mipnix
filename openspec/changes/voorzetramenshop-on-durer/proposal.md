## Why

The voorzetramenshop webshop needs a production home. It ships its own NixOS module and (as of the merged `nix-package-and-deploy-migrations` change) a runnable package + automatic migration step, so durer — which already fronts `pimsnel.com`/`nuremberg.pimsnel.com` with nginx + ACME — is the natural host. Deploying it as a private flake input lets new versions ship with a single `nix flake update voorzetramenshop` + rebuild, with `flake.lock` as the audit trail and rollback point.

## What Changes

- Add `voorzetramenshop` as a **private** flake input (`git+ssh://git@github.com/mintglasinlood/voorzetramenshop.git`) in `flake.nix`, with `inputs.nixpkgs.follows = "nixpkgs"` to keep the closure aligned with durer's nixos-26.05.
- Import `inputs.voorzetramenshop.nixosModules.default` into the durer host module and enable `services.voorzetramenshop` with `domain = "mintshop.nuremberg.pimsnel.com"`, `port = 3001` (3000 is taken by `services.bluesky-pds`), `maintenanceMode = true` for launch, and `environmentFile` sourced from agenix. The `package` option is left to its default (the flake's `voorzetramenshop` package).
- Add an agenix secret `voorzetramenshop-env` (`secrets/voorzetramenshop-env.age`, `publicKeys = [ pim durer ]`) holding `AUTH_SECRET`, `AUTH_URL`, `MOLLIE_API_KEY`, `EMAIL_SERVER` (AWS SES SMTP), and `EMAIL_FROM`. `DATABASE_URL` and `MAINTENANCE_MODE` are owned by the module and excluded.
- Compose with durer's existing nginx + `security.acme` (the module's `enableACME`/`forceSSL`/email defaults yield via `lib.mkDefault`; the new vhost key is distinct from existing hosts).
- Document the deploy/rollback workflow and a pre-launch checklist (DNS, SES out of sandbox, derived SMTP password, `nix flake show` output confirmation).

## Capabilities

### New Capabilities
- `voorzetramenshop-hosting`: Hosting the voorzetramenshop webshop on durer — private flake input wiring, NixOS module import + service configuration, agenix-backed environment secret, nginx/ACME composition, and the version-bump deploy/rollback workflow.

### Modified Capabilities
<!-- None. The module sets security.acme/nginx defaults via lib.mkDefault, so durer's existing durer-nginx-acme requirements are unaffected. -->

## Impact

- **Files modified**: `flake.nix` (new private input), `modules/HOSTS/durer-server/configuration.nix` (module import + `services.voorzetramenshop` + `age.secrets."voorzetramenshop-env"`), `secrets/secrets.nix` (new recipient entry).
- **New files**: `secrets/voorzetramenshop-env.age` (created via `agenix -e`; already authored by the user).
- **New DNS**: `mintshop.nuremberg.pimsnel.com` → durer (covered by the `*.nuremberg.pimsnel.com` wildcard already added).
- **New service surface**: PostgreSQL db/user `voorzetramenshop`, a `prisma migrate deploy` oneshot, a hardened DynamicUser systemd service on `127.0.0.1:3001`, and an nginx vhost with its own ACME cert.
- **External dependency**: AWS SES (SMTP send) must be reachable and out of sandbox for magic-link login to work — magic-link is the only auth path.
- **Upstream dependency**: relies on `voorzetramenshop`'s merged `nix-package-and-deploy-migrations` outputs (`packages.<system>.voorzetramenshop`, migrate oneshot); confirm via `nix flake show` before the rebuild.
- **No new firewall ports**: nginx (80/443) fronts the service; 3001 is loopback-only.
