# Tasks

## 1. IAM user in nivis

- [ ] 1.1 In `nivis/stack/060_ses_studio_mint_shop/domain.nix` (repository `wasnel-awsaccount-104144963194-main`), add `aws_iam_user` `studio-mint-v3-smtp`, an `aws_iam_user_policy` allowing only `ses:SendRawEmail` on the `studio-mint.shop` identity ARN with `ses:FromAddress` `*@studio-mint.shop`, and an `aws_iam_access_key`; verify `./nivis/stackctl production 060_ses_studio_mint_shop plan` shows exactly these three to add and no change to the identity or DKIM records
- [ ] 1.2 Apply and commit in that repository; verify `aws iam list-attached-user-policies` / `get-user-policy` for `studio-mint-v3-smtp` shows only the one statement

## 2. Secret and deploy

- [ ] 2.1 Read the access key `id` and `ses_smtp_password_v4` from the nivis state and set `EMAIL_SERVER=smtp://<id>:<url-encoded password>@email-smtp.eu-central-1.amazonaws.com:587` and `EMAIL_FROM="Studio MINT <noreply@studio-mint.shop>"` in `secrets/studio-mint-v3-env.age`; verify by decrypting that the other keys are unchanged
- [ ] 2.2 Deploy durer with `rme deploy_remote durer`; verify on durer with `swaks` (or `openssl s_client -starttls smtp`) using the new credentials that SES accepts a test mail from `noreply@studio-mint.shop` to the maintainer

## 3. Production access

- [ ] 3.1 File the production-access request with `aws sesv2 put-account-details` (transactional, website `https://studio-mint.shop`); verify `aws sesv2 get-account` shows the review as pending, and later `ProductionAccessEnabled: true`

## 4. End-to-end on staging

- [ ] 4.1 After v3's `transactional-mail` is deployed, request a magic link on `https://v3.studio-mint.shop/inloggen`; verify it arrives, the headers show `dkim=pass` for `studio-mint.shop`, and `/admin/mail` lists it as sent

## Workflow follow-up

- Archive this change and set bean `mipnix-t58k` to completed with the archive link.
