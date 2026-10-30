# Proposal

Bean: [mipnix-t58k](../../../.beans/mipnix-t58k--studio-mint-v3-mail-via-aws-ses.md) (from the v3 epic `v3.studio-mint.shop-trys`, "Transactionele mail via AWS SES")

## Why

The v3 shop gets an outbox that sends all its mail over SMTP (v3 change
`transactional-mail`). On durer that SMTP server must be Amazon SES, which
already holds the verified, DKIM-signed identity `studio-mint.shop`. Two
things are missing: credentials that may only send for that identity, and
production access, because the SES account is still in the sandbox
(`ProductionAccessEnabled: false`, 200 mails a day, verified recipients only).

## What Changes

- nivis (`060_ses_studio_mint_shop`): an IAM user `studio-mint-v3-smtp` with
  a policy that allows only `ses:SendRawEmail` on the `studio-mint.shop`
  identity in `eu-central-1`, and one access key whose SES SMTP password
  (`ses_smtp_password_v4`) comes from the provider.
- mipnix: `studio-mint-v3-env.age` gets `EMAIL_SERVER` pointing at
  `email-smtp.eu-central-1.amazonaws.com:587` with those credentials.
- The SES account requests production access for transactional mail.

Not in this change: DMARC from `p=none` to `p=quarantine` (after a few weeks
of reports), bounce handling through SNS.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `studio-mint-v3-hosting`: the environment secret's mail settings now point
  at SES with dedicated, least-privilege credentials; the account sends
  outside the sandbox.

## Impact

- nivis repository `wasnel-awsaccount-104144963194-main`:
  `nivis/stack/060_ses_studio_mint_shop/domain.nix` and an apply of that domain.
- mipnix: `secrets/studio-mint-v3-env.age` re-encrypted, then a deploy.
- AWS: one IAM user and access key; a production-access request to SES.
