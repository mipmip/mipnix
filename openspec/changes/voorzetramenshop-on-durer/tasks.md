## 1. Add the private flake input

- [x] 1.1 Add `voorzetramenshop.url = "git+ssh://git@github.com/mintglasinlood/voorzetramenshop.git";` to `inputs` in `flake.nix`
- [x] 1.2 Add `voorzetramenshop.inputs.nixpkgs.follows = "nixpkgs";` next to it
- [ ] 1.3 Confirm SSH agent forwarding reaches the private repo (`ssh -A durer`, then `ssh -T git@github.com` resolves to the mintglasinlood account)

## 2. Add the agenix secret entry

- [x] 2.1 Add `"voorzetramenshop-env.age".publicKeys = [ pim durer ];` to `secrets/secrets.nix`
- [x] 2.2 Verify `secrets/voorzetramenshop-env.age` exists and decrypts for `pim` (it was authored via `agenix -e`)
- [ ] 2.3 Confirm the env body has `AUTH_SECRET`, `AUTH_URL=https://mintshop.nuremberg.pimsnel.com`, `MOLLIE_API_KEY`, `EMAIL_SERVER` (SES SMTP, password URL-encoded), `EMAIL_FROM`; and does NOT have `DATABASE_URL` or `MAINTENANCE_MODE` <!-- needs interactive decrypt (passphrase) -->`

## 3. Wire the service into the durer module

- [x] 3.1 Import `inputs.voorzetramenshop.nixosModules.default` in `modules/HOSTS/durer-server/configuration.nix` (`flake.modules.nixos.durer`)
- [x] 3.2 Add `age.secrets."voorzetramenshop-env" = { file = ../../../secrets/voorzetramenshop-env.age; };` (agenix defaults: `root:root`, `0400`)
- [x] 3.3 Set `services.voorzetramenshop = { enable = true; domain = "mintshop.nuremberg.pimsnel.com"; port = 3001; maintenanceMode = true; environmentFile = config.age.secrets."voorzetramenshop-env".path; };` (do NOT set `package`)

## 4. Verify upstream contract and secret access (pre-rebuild)

- [ ] 4.1 On durer (agent forwarded): `cd ~/mipnix && nix flake update voorzetramenshop` to lock the revision
- [ ] 4.2 `nix flake show` on the input confirms `nixosModules.default` and `packages.<system>.voorzetramenshop` exist
- [ ] 4.3 Read the upstream module source: confirm the app service AND migrate oneshot consume the secret via systemd `EnvironmentFile=` (root-read). If either reads it as the DynamicUser, change the secret to a shared group + `mode = "0440"` in 3.2
- [ ] 4.4 Confirm the module proxies to `127.0.0.1:3001` and that 3001 is otherwise free on durer

## 5. Build and deploy

- [ ] 5.1 `nixos-rebuild build` (or dry-build) for durer evaluates without nginx/ACME/port conflicts
- [ ] 5.2 `rme up_machine` (sudo `nixos-rebuild switch`) on durer
- [ ] 5.3 Verify the `prisma migrate deploy` oneshot completed and the app service is listening on `127.0.0.1:3001`
- [ ] 5.4 Verify ACME issued a cert for `mintshop.nuremberg.pimsnel.com` and the existing `pimsnel.com` / `nuremberg.pimsnel.com` vhosts still serve

## 6. Launch checklist

- [ ] 6.1 DNS: `mintshop.nuremberg.pimsnel.com` resolves to durer (covered by the `*.nuremberg.pimsnel.com` wildcard)
- [ ] 6.2 SES: account is out of sandbox (or the admin recipient is verified) and `EMAIL_FROM` is a verified SES identity
- [ ] 6.3 Send a test magic-link and confirm login works end-to-end while `maintenanceMode = true`
- [ ] 6.4 Document the deploy/rollback workflow location (this change's design.md) for future version bumps

## 7. Wrap-up

- [x] 7.1 `openspec validate voorzetramenshop-on-durer` passes
- [ ] 7.2 Note rollback procedure verified: revert `flake.lock` bump (git) or `nixos-rebuild --rollback`
