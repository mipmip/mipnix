# Design

## Context

See proposal.md. The SES identity and its DKIM records are managed in nivis
(`060_ses_studio_mint_shop/domain.nix`), with `preventDestroy`. That domain
has no IAM resources yet; the AWS provider there runs in `eu-central-1`.

## Goals / Non-Goals

**Goals:**
- Credentials that can do one thing: send as `studio-mint.shop`.
- Customer addresses reachable, so v3 can go live on mail later.

**Non-Goals:**
- Reusing these credentials for v1. v1 keeps its own relay.
- SNS bounce and complaint topics.

## Decisions

### IAM user in the SES domain of nivis

The user, its inline policy and the access key live in
`060_ses_studio_mint_shop`, next to the identity they are scoped to. The
policy resource is the identity ARN
`arn:aws:ses:eu-central-1:104144963194:identity/studio-mint.shop`, action
`ses:SendRawEmail`, with a condition `ses:FromAddress` matching
`*@studio-mint.shop`.

Alternative: a separate IAM domain. Rejected: the user has no meaning without
the identity.

### SMTP password from the provider

`aws_iam_access_key` exposes `ses_smtp_password_v4`, derived for the
provider's region. The maintainer reads `id` and that attribute from the nivis
state once and pastes them into the agenix secret. No derivation script.

The key also sits in the nivis state in S3, which is encrypted and private to
the account. Rotation: replace the access key resource and repeat the secret
step.

### Production access via the SES API

`aws sesv2 put-account-details --production-access-enabled --mail-type
TRANSACTIONAL --website-url https://studio-mint.shop --use-case-description …
--contact-language EN` files the request. AWS answers by mail, usually within
a day. Until then the sandbox limits only affect staging, which is fine.

## Risks / Trade-offs

- [Request denied or delayed] → staging keeps working for verified addresses;
  launch waits on it. The description names transactional mail only (login,
  order, payment, shipping).
- [Secret key in nivis state] → state bucket is private and encrypted; the
  policy limits damage to sending as the shop.

## Migration Plan

1. nivis: add the resources, plan, apply.
2. Read the key, update `studio-mint-v3-env.age`, deploy durer.
3. File the production-access request.
4. After v3's `transactional-mail` is deployed: request a magic link on
   staging and check it arrives with DKIM pass.

Rollback: revert the secret to the previous relay and redeploy; the IAM user
can stay or be removed in nivis.
