# studio-mint-v3-hosting Specification

## Purpose
Host the v3 Studio MINT webshop on durer as a staging site next to v1: its private flake input, the service and its secret, the DNS name, the database backup, and how the first admin gets in.

## Requirements

### Requirement: Private flake input for v3
The mipnix flake SHALL declare `studio-mint-v3` as a private git input for `mintglasinlood/v3.studio-mint.shop` over SSH, with `inputs.nixpkgs.follows = "nixpkgs"`.

#### Scenario: Input resolves and follows nixpkgs
- **WHEN** `flake.nix` is evaluated
- **THEN** `inputs.studio-mint-v3` points at the v3 repository and its nixpkgs follows the top-level `nixpkgs`
- **AND** `nixosModules.default` and `packages.x86_64-linux.studio-mint-v3` are present on the locked input

### Requirement: v3 service on durer in maintenance mode
durer SHALL enable `services.studio-mint-v3` with `domain = "v3.studio-mint.shop"`, `port = 3003`, `maintenanceMode = true` and the package from the v3 flake, without overriding the package.

#### Scenario: Visitor during staging
- **WHEN** a visitor without a session opens `https://v3.studio-mint.shop/`
- **THEN** the maintenance page is served with status 503 over a valid certificate

#### Scenario: Login stays reachable
- **WHEN** someone opens `https://v3.studio-mint.shop/inloggen`
- **THEN** the login page is served with status 200

#### Scenario: Migrations ran
- **WHEN** durer has activated the configuration
- **THEN** `studio-mint-v3-migrate.service` has finished successfully and `studio-mint-v3.service` is active

### Requirement: v3 runs next to v1 without touching it
Enabling v3 SHALL NOT change the v1 service, its database `voorzetramenshop`, its port 3001, its vhost, or the static-site vhosts.

#### Scenario: Both shops answer
- **WHEN** the configuration is active
- **THEN** `v1.studio-mint.shop`, `v3.studio-mint.shop`, `studio-mint.shop` and `v2.studio-mint.shop` each answer from their own vhost
- **AND** v3 uses the database and role `studio_mint_v3` on the existing PostgreSQL

### Requirement: Environment secret via agenix
One agenix secret `studio-mint-v3-env.age`, decryptable by `pim` and `durer`, SHALL supply the environment file. It SHALL contain `AUTH_SECRET`, `AUTH_URL`, `EMAIL_SERVER` and `EMAIL_FROM`, and SHALL NOT contain `DATABASE_URL` or `MAINTENANCE_MODE`, which the module owns.

#### Scenario: Recipients
- **WHEN** `secrets/secrets.nix` is evaluated
- **THEN** `studio-mint-v3-env.age` lists `publicKeys = [ pim durer ]`

#### Scenario: Secret differs from v1
- **WHEN** both env files are decrypted
- **THEN** the `AUTH_SECRET` of v3 differs from the one of v1

#### Scenario: Mail goes through SES with v3's own credentials
- **WHEN** the env file is decrypted
- **THEN** `EMAIL_SERVER` points at `email-smtp.eu-central-1.amazonaws.com:587` with the credentials of the IAM user `studio-mint-v3-smtp`, and `EMAIL_FROM` is `Studio MINT <noreply@studio-mint.shop>`

### Requirement: DNS name for v3
The Route 53 zone `studio-mint.shop`, managed in nivis, SHALL hold an A record `v3.studio-mint.shop` pointing at durer's public address, before the first deploy that enables the vhost.

#### Scenario: Name resolves before ACME runs
- **WHEN** the deploy activates the v3 vhost
- **THEN** `v3.studio-mint.shop` already resolves to `178.104.252.76`, so the HTTP-01 challenge can succeed

### Requirement: The v3 database is backed up
durer SHALL back up the `studio_mint_v3` database as its own restic dataset `durer-studio-mint-v3`, following the existing host-backups rules.

#### Scenario: Hourly dump
- **WHEN** the backup timer for `durer-studio-mint-v3` fires
- **THEN** a `pg_dump` of `studio_mint_v3` is written, snapshotted to `/ResticBackups/durer-studio-mint-v3`, and removed from disk afterwards

### Requirement: First admin on staging gets in without a known password
Staging SHALL NOT contain the development seed admin or its published password. The first admin account SHALL be created on durer as a user with role `ADMIN` and no password, who logs in with a magic link.

#### Scenario: Creating the first admin
- **WHEN** the maintainer inserts an `ADMIN` user with their email into `studio_mint_v3` and requests a magic link on `/inloggen`
- **THEN** the link arrives by mail and lands them in `/admin`

#### Scenario: Development credentials do not work
- **WHEN** someone tries `admin@studio-mint.shop` with the development password on staging
- **THEN** the login fails

### Requirement: SMTP credentials may only send as studio-mint.shop
The IAM user behind v3's SMTP credentials SHALL be allowed `ses:SendRawEmail` on the `studio-mint.shop` identity in `eu-central-1` and nothing else, and SHALL be managed in nivis.

#### Scenario: Sending as the shop
- **WHEN** the shop sends from `noreply@studio-mint.shop` with these credentials
- **THEN** SES accepts the mail and signs it with the domain's DKIM key

#### Scenario: Any other use
- **WHEN** the credentials are used for another identity or another AWS action
- **THEN** AWS refuses the request

### Requirement: The SES account sends outside the sandbox
The SES account in `eu-central-1` SHALL have production access for transactional mail, so the shop can mail any customer address.

#### Scenario: Mail to an unverified customer address
- **WHEN** the shop sends a magic link to an address that is not verified in SES
- **THEN** SES accepts it
