# Spec Delta

## MODIFIED Requirements

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

## ADDED Requirements

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
