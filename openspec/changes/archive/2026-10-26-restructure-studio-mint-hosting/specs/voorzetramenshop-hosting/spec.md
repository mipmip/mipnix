# Voorzetramenshop Hosting

## MODIFIED Requirements

### Requirement: Private flake input for voorzetramenshop

The mipnix flake SHALL declare the shop as a private git input named
`studio-mint-v1` at
`git+ssh://git@github.com/mintglasinlood/v1.studio-mint.shop.git`, and SHALL
pin its nixpkgs to mipnix's nixpkgs via `inputs.nixpkgs.follows = "nixpkgs"`.
The input SHALL name the repository as it is called now; the old name
`voorzetramenshop` SHALL NOT be relied on, even though GitHub still redirects
it.

#### Scenario: Input is declared and follows nixpkgs

- **WHEN** `flake.nix` is evaluated
- **THEN** `inputs.studio-mint-v1` resolves to the
  `mintglasinlood/v1.studio-mint.shop` repo over SSH
- **AND** `inputs.studio-mint-v1.inputs.nixpkgs` follows the top-level `nixpkgs`
  (nixos-26.05), so the closure is not duplicated

#### Scenario: Authenticated fetch via SSH agent forwarding

- **WHEN** `nix flake update studio-mint-v1` is run in a session with a
  forwarded SSH agent that has access to the private repo
- **THEN** the input is fetched successfully and `flake.lock` records the new
  revision

#### Scenario: Expected outputs are present before rebuild

- **WHEN** `nix flake show` is run against the locked input
- **THEN** `nixosModules.default` and `packages.<system>.voorzetramenshop` are
  both present, because the repository was renamed but the module and package
  inside it were not

### Requirement: voorzetramenshop service enabled on durer

The durer host module SHALL import `inputs.studio-mint-v1.nixosModules.default`
and enable `services.voorzetramenshop` bound to a loopback port that does not
collide with existing services. It SHALL NOT override the `package` option
(defaulting to the flake's `voorzetramenshop` package).

#### Scenario: Service configured with non-colliding port

- **WHEN** the durer configuration is evaluated
- **THEN** `services.voorzetramenshop.enable = true`,
  `domain = "v1.studio-mint.shop"`, and `port = 3001`
- **AND** port 3001 is free on durer (3000 was historically used by
  `services.bluesky-pds`; 3001 stays clear even if PDS is reintroduced)

#### Scenario: Launch is gated behind maintenance mode

- **WHEN** the service starts for the initial launch
- **THEN** `maintenanceMode = true` is set, causing the module to export
  `MAINTENANCE_MODE=true`
- **AND** `MAINTENANCE_MODE` is NOT also set in the environment file (the module
  is the single source of truth)

#### Scenario: Database and migrations are managed by the module

- **WHEN** the service is activated
- **THEN** PostgreSQL is enabled with a `voorzetramenshop` database/user over
  the local socket
- **AND** a `prisma migrate deploy` oneshot runs and completes before the
  application service starts

#### Scenario: The database keeps its name

- **WHEN** the repository rename is applied
- **THEN** the database, the `services.voorzetramenshop` option and the
  `durer-voorzetramenshop` backup dataset SHALL keep their names
- **AND** no migration or dump rename SHALL be required by the rename

### Requirement: Environment secret via agenix

A single agenix secret SHALL supply the application's environment file, and it
SHALL be decryptable both by the maintainer (for editing) and by durer (for
runtime activation). The DynamicUser service identity SHALL NOT be required as
a decryption recipient.

#### Scenario: Secret recipients

- **WHEN** `secrets/secrets.nix` is evaluated
- **THEN** `voorzetramenshop-env.age` lists `publicKeys = [ pim durer ]`

#### Scenario: Environment file is consumed by the units

- **WHEN** the application service and the migrate oneshot start
- **THEN** both receive the decrypted env file via systemd `EnvironmentFile=`,
  read by the service manager as root before privileges drop to the DynamicUser

#### Scenario: Required keys present, module-owned keys absent

- **WHEN** the env file is inspected
- **THEN** it contains `AUTH_SECRET`, `AUTH_URL` (= `https://v1.studio-mint.shop`),
  `MOLLIE_API_KEY`, `EMAIL_SERVER`, and `EMAIL_FROM`
- **AND** it does NOT contain `DATABASE_URL` or `MAINTENANCE_MODE` (both owned
  by the module)

#### Scenario: A stale AUTH_URL does not break login

- **WHEN** `AUTH_URL` disagrees with the host the request arrived on
- **THEN** `AUTH_TRUST_HOST = "true"`, set on the service in durer's
  configuration, SHALL make Auth.js derive its base URL from the
  nginx-forwarded Host header
- **AND** login SHALL redirect to the domain the request came in on

### Requirement: nginx and ACME composition

The shop module's nginx vhost and ACME settings SHALL compose with durer's
existing nginx/ACME configuration without clobbering existing vhosts or the
existing ACME account email. The shop SHALL answer on exactly one name, derived
from its `domain` option, and SHALL NOT claim the apex.

#### Scenario: New vhost coexists with existing ones

- **WHEN** the durer configuration is evaluated
- **THEN** a vhost for `v1.studio-mint.shop` exists with `enableACME = true` and
  `forceSSL = true`
- **AND** the existing `pimsnel.com` and `nuremberg.pimsnel.com` vhosts are
  unchanged

#### Scenario: Existing ACME email is preserved

- **WHEN** the module sets `security.acme.defaults.email` via `lib.mkDefault`
- **THEN** durer's explicitly set `pim@pimsnel.com` wins

#### Scenario: Per-host certificate issuance

- **WHEN** ACME provisions a certificate for `v1.studio-mint.shop`
- **THEN** an HTTP-01 challenge succeeds against the per-host FQDN (no
  wildcard/DNS-01 certificate is required)

#### Scenario: The apex is left to the static site

- **WHEN** the shop's `domain` is set to `v1.studio-mint.shop`
- **THEN** the module SHALL define no vhost for `studio-mint.shop`
- **AND** the apex vhost SHALL be free for the static site to claim, with no
  conflicting definition in `services.nginx.virtualHosts`

### Requirement: Version-bump deploy and rollback workflow

Deploying a new version SHALL update the flake input as the user (with agent
auth available) before deploying, and rollback SHALL be possible without
redeploying code.

#### Scenario: Deploy a new version

- **WHEN** the maintainer runs `nix flake update studio-mint-v1` as the user,
  then `rme deploy_remote durer`
- **THEN** the input fetch happens during the user-run update (agent native) and
  writes `flake.lock`
- **AND** deploy-rs evaluates the already-locked store path, building locally
  without needing durer to fetch the private input

#### Scenario: Roll back to the previous version

- **WHEN** a deployed version is unreachable after activation
- **THEN** deploy-rs's magic rollback automatically reverts durer to the
  previous generation
- **WHEN** a deployed version is reachable but misbehaving
- **THEN** the maintainer can revert the `flake.lock` bump (git) and re-deploy,
  or run `nixos-rebuild --rollback` on durer

#### Scenario: The wrapper names the right input

- **WHEN** the maintainer reads the version-bump instructions in
  `RUNME.d/deploy.sh`
- **THEN** they SHALL name `studio-mint-v1`, not `voorzetramenshop`, so the
  documented command is one that resolves
