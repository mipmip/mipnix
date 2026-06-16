## ADDED Requirements

### Requirement: Private flake input for voorzetramenshop

The mipnix flake SHALL declare `voorzetramenshop` as a private git input at `git+ssh://git@github.com/mintglasinlood/voorzetramenshop.git`, and SHALL pin its nixpkgs to mipnix's nixpkgs via `inputs.nixpkgs.follows = "nixpkgs"`.

#### Scenario: Input is declared and follows nixpkgs

- **WHEN** `flake.nix` is evaluated
- **THEN** `inputs.voorzetramenshop` resolves to the `mintglasinlood/voorzetramenshop` repo over SSH
- **AND** `inputs.voorzetramenshop.inputs.nixpkgs` follows the top-level `nixpkgs` (nixos-26.05), so the closure is not duplicated

#### Scenario: Authenticated fetch via SSH agent forwarding

- **WHEN** `nix flake update voorzetramenshop` is run on durer in a session with a forwarded SSH agent that has access to the private repo
- **THEN** the input is fetched successfully and `flake.lock` records the new revision

#### Scenario: Expected outputs are present before rebuild

- **WHEN** `nix flake show` is run against the locked input
- **THEN** `nixosModules.default` and `packages.<system>.voorzetramenshop` are both present

### Requirement: voorzetramenshop service enabled on durer

The durer host module SHALL import `inputs.voorzetramenshop.nixosModules.default` and enable `services.voorzetramenshop` bound to a loopback port that does not collide with existing services. It SHALL NOT override the `package` option (defaulting to the flake's `voorzetramenshop` package).

#### Scenario: Service configured with non-colliding port

- **WHEN** the durer configuration is evaluated
- **THEN** `services.voorzetramenshop.enable = true`, `domain = "mintshop.nuremberg.pimsnel.com"`, and `port = 3001`
- **AND** port 3001 is free on durer (3000 was historically used by `services.bluesky-pds`; 3001 stays clear even if PDS is reintroduced)

#### Scenario: Launch is gated behind maintenance mode

- **WHEN** the service starts for the initial launch
- **THEN** `maintenanceMode = true` is set, causing the module to export `MAINTENANCE_MODE=true`
- **AND** `MAINTENANCE_MODE` is NOT also set in the environment file (the module is the single source of truth)

#### Scenario: Database and migrations are managed by the module

- **WHEN** the service is activated
- **THEN** PostgreSQL is enabled with a `voorzetramenshop` database/user over the local socket
- **AND** a `prisma migrate deploy` oneshot runs and completes before the application service starts

### Requirement: Environment secret via agenix

A single agenix secret SHALL supply the application's environment file, and it SHALL be decryptable both by the maintainer (for editing) and by durer (for runtime activation). The DynamicUser service identity SHALL NOT be required as a decryption recipient.

#### Scenario: Secret recipients

- **WHEN** `secrets/secrets.nix` is evaluated
- **THEN** `voorzetramenshop-env.age` lists `publicKeys = [ pim durer ]`

#### Scenario: Environment file is consumed by the units

- **WHEN** the application service and the migrate oneshot start
- **THEN** both receive the decrypted env file via systemd `EnvironmentFile=`, read by the service manager as root before privileges drop to the DynamicUser

#### Scenario: Required keys present, module-owned keys absent

- **WHEN** the env file is inspected
- **THEN** it contains `AUTH_SECRET`, `AUTH_URL` (= `https://mintshop.nuremberg.pimsnel.com`), `MOLLIE_API_KEY`, `EMAIL_SERVER`, and `EMAIL_FROM`
- **AND** it does NOT contain `DATABASE_URL` or `MAINTENANCE_MODE` (both owned by the module)

### Requirement: nginx and ACME composition

The voorzetramenshop module's nginx vhost and ACME settings SHALL compose with durer's existing nginx/ACME configuration without clobbering existing vhosts or the existing ACME account email.

#### Scenario: New vhost coexists with existing ones

- **WHEN** the durer configuration is evaluated
- **THEN** a vhost for `mintshop.nuremberg.pimsnel.com` exists with `enableACME = true` and `forceSSL = true`
- **AND** the existing `pimsnel.com` and `nuremberg.pimsnel.com` vhosts are unchanged

#### Scenario: Existing ACME email is preserved

- **WHEN** the module sets `security.acme.defaults.email` via `lib.mkDefault`
- **THEN** durer's explicitly set `pim@pimsnel.com` wins

#### Scenario: Per-host certificate issuance

- **WHEN** ACME provisions a certificate for `mintshop.nuremberg.pimsnel.com`
- **THEN** an HTTP-01 challenge succeeds against the per-host FQDN (no wildcard/DNS-01 certificate is required)

### Requirement: Version-bump deploy and rollback workflow

Deploying a new version SHALL be a documented two-step operation that updates the flake input as the user (with agent auth available) before the privileged rebuild, and rollback SHALL be possible without redeploying code.

#### Scenario: Deploy a new version

- **WHEN** the maintainer runs `nix flake update voorzetramenshop` as the user, then `rme up_machine`
- **THEN** the input fetch happens during the user-run update (agent available) and writes `flake.lock`
- **AND** the subsequent sudo rebuild reads the already-locked store path without needing the SSH agent

#### Scenario: Roll back to the previous version

- **WHEN** a deployed version misbehaves
- **THEN** the maintainer can revert the `flake.lock` bump (git) and rebuild, or run `nixos-rebuild --rollback`
