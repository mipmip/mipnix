## 1. ACME and Nginx

- [x] 1.1 Add `security.acme` configuration for `nuremberg.pimsnel.com` with HTTP-01 challenge and accepted terms of service
- [x] 1.2 Add nginx virtual host on ports 80/443 — ACME challenge handler on 80, static health page on 443
- [x] 1.3 Open ports 80 and 443 in durer firewall

## 2. Ergo IRC Configuration

- [x] 2.1 Configure `services.ergochat.settings` with server identity (`nuremberg.pimsnel.com`), network name, and TLS listener on `:6697` pointing to ACME cert paths
- [x] 2.2 Disable plaintext listeners (remove default port 6667)
- [x] 2.3 Enable SASL-required mode (`require-sasl.enabled = true`)
- [x] 2.4 Disable self-registration (`accounts.registration.enabled = false`)
- [x] 2.5 Configure always-on bouncer mode (`accounts.multiclient.always-on = "opt-out"`)
- [x] 2.6 Configure an IRC operator with a bcrypt-hashed password
- [x] 2.7 Add Ergo service user to the `acme` group for cert file access
- [x] 3.1 Add ACME renewal hook to send SIGHUP to the Ergo service on cert renewal

## 3. Certificate Reload

- [x] 3.1 Add ACME renewal hook to send SIGHUP to the Ergo service on cert renewal

## 4. Verification

- [x] 4.1 Verify `nixos-rebuild` succeeds with the new configuration (dry run or build)
- [x] 4.2 Document initial account creation steps (oper login + `/NS SAREGISTER`)

### Account Creation Steps

After deploying, create your first account:

1. Connect with an IRC client to `nuremberg.pimsnel.com:6697` (TLS, no SASL yet — won't work until you have an account, so temporarily set `require-sasl.enabled = false`, rebuild, create the account, then re-enable)
2. Alternatively, on the server directly:
   ```
   # Connect locally (if a loopback listener is temporarily added)
   /OPER <opname> <password>
   /NS SAREGISTER <username> <password>
   ```
3. After creating the account, re-enable `require-sasl.enabled = true` and rebuild

**Recommended approach**: Temporarily disable `require-sasl` for initial bootstrap, connect, `/OPER pim <password>`, `/NS SAREGISTER pim <your-user-password>`, then re-enable require-sasl and rebuild.
