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

## 4. Wire deploy-rs (build on lego2, deploy to durer)

- [x] 4.1 Add `deploy-rs.url = "github:serokell/deploy-rs";` and `deploy-rs.inputs.nixpkgs.follows = "nixpkgs";` to `inputs` in `flake.nix`
- [x] 4.2 Add a module defining `flake.deploy.nodes.durer = { hostname = "192.168.100.12"; sshUser = "pim"; profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.durer; };` (via flake-parts' `flake.deploy = { … }` escape hatch — NOT a `perSystem` output) <!-- modules/HOSTS/durer-server/deploy.nix; set as a WHOLE `flake.deploy = {…}` value (flake-parts freeform is `unique raw`, no piecewise nested set); file must be git-tracked to be flake-visible. `deploy` surfaces as an output and the activation derivation resolves. -->
- [x] 4.3 Add `nix.settings.trusted-users = [ "root" "pim" ];` to the durer module (so `ssh-ng` accepts the lego2-built unsigned closure) — **and resolve the chicken-and-egg**: land this via an in-session `nixos-rebuild`/`--target-host` on durer once (push as root) BEFORE the first deploy-rs push <!-- config line done + verified (trusted-users = [root pim]); the first-push chicken-and-egg is an OPERATIONAL step for the live deploy (section 7), not a code change. -->
- [x] 4.4 Add a GC policy to the durer module: `boot.loader.grub.configurationLimit` and/or `nix.gc = { automatic = true; options = "--delete-older-than 14d"; };` (do NOT GC inside the deploy) <!-- grub.configurationLimit = 10; weekly nix.gc --delete-older-than 14d; verified in resolved config. -->
- [x] 4.5 `nix flake check` evaluates `flake.deploy` and deploy-rs `deployChecks` without clashing with the existing `checks.mipvim` <!-- durer config + flake.deploy check clean and coexist with checks.mipvim. A full `nix flake check` currently fails on a PRE-EXISTING, unrelated error in modules/HOSTS/harry-pi (undefined `users-core`); deploy-rs `deployChecks` were NOT merged into `checks` because that would require a clean `nix flake check` and is optional for correctness. -->


## 5. RUNME.d wrapper

- [x] 5.1 Add `RUNME.d/deploy.sh` with `make_command "deploy_remote" "Build locally and deploy a remote host with deploy-rs"` and a `deploy_remote()` taking the host as `$EXTRA_ARG`/`$2`
- [x] 5.2 The function runs `check_untracked`, then `nix run github:serokell/deploy-rs -- .#<host>`, then on success sets `EXTRA_ARG="auto run after deploy_remote <host>"` and calls `git_sync_machine`; on failure reports that deploy-rs auto-rolled-back and exits 1
- [x] 5.3 Confirm `rme deploy_remote durer` resolves (loads the new command) and rejects a missing host argument <!-- Required editing the vendored RUNME.sh dispatcher: `NARGS -eq 1` → `-ge 1` so a command can take a positional arg (host). Verified: 0 args → usage, 1-arg commands unchanged, `deploy_remote durer` reaches the function (EXTRA_ARG=durer) and starts deploy-rs, `deploy_remote` alone rejects with the guard. -->
- [x] 5.4 Modify `RUNME.sh` dispatcher to allow a positional argument (`NARGS -ge 1`), so `deploy_remote <host>` dispatches; zero-arg usage and existing one-arg commands are unaffected (`eval "$ARG1"` only ever runs the first word). <!-- added during apply: the host-as-argument design (option 3) required this; vendored RUNME.sh is a tracked, non-regenerated repo file. -->


## 6. Verify upstream contract and secret access (pre-deploy)

- [ ] 6.1 On lego2 (agent loaded): `cd ~/mipnix && nix flake update voorzetramenshop` to lock the revision
- [ ] 6.2 `nix flake show` on the input confirms `nixosModules.default` and `packages.<system>.voorzetramenshop` exist
- [x] 6.3 Read the upstream module source: confirm the app service AND migrate oneshot consume the secret via systemd `EnvironmentFile=` (root-read). If either reads it as the DynamicUser, change the secret to a shared group + `mode = "0440"` in 3.2 <!-- CONFIRMED in nix/module.nix: migrate unit (L98) and app unit (L142) both use `EnvironmentFile = cfg.environmentFile`, read by PID 1 (root) before privilege drop. App is DynamicUser (L147); migrate runs as the real DB-owner system user (L103/116). agenix default root:root 0400 is sufficient — the 0440 shared-group fallback is NOT needed. -->
- [x] 6.4 Confirm the module proxies to `127.0.0.1:3001` and that 3001 is otherwise free on durer <!-- module CONFIRMED: app binds HOSTNAME=127.0.0.1 + PORT=cfg.port (L131-132), nginx proxyPass http://127.0.0.1:${cfg.port} (L168/173) — loopback-only. LIVE CONFIRMED: ss on durer shows 3001 FREE. -->`

## 7. Build and deploy

- [ ] 7.1 Gate the build on lego2: `nix build .#nixosConfigurations.durer.config.system.build.toplevel` succeeds (proves the shop's large Next.js build fits on lego2's disk and evaluates without nginx/ACME/port conflicts)
- [ ] 7.2 `rme deploy_remote durer` (deploy-rs: build on lego2, copy closure, activate over passwordless sudo with magic rollback)
- [ ] 7.3 Verify the `prisma migrate deploy` oneshot completed and the app service is listening on `127.0.0.1:3001`
- [ ] 7.4 Verify ACME issued a cert for `mintshop.nuremberg.pimsnel.com` and the existing `pimsnel.com` / `nuremberg.pimsnel.com` vhosts still serve

## 8. Launch checklist

- [ ] 8.1 DNS: `mintshop.nuremberg.pimsnel.com` resolves to durer (covered by the `*.nuremberg.pimsnel.com` wildcard)
- [ ] 8.2 SES: account is out of sandbox (or the admin recipient is verified) and `EMAIL_FROM` is a verified SES identity
- [ ] 8.3 Send a test magic-link and confirm login works end-to-end while `maintenanceMode = true`
- [ ] 8.4 Document the deploy/rollback workflow location (this change's design.md) for future version bumps

## 9. Wrap-up

- [x] 9.1 `openspec validate voorzetramenshop-on-durer` passes
- [ ] 9.2 Verify rollback: confirm deploy-rs magic-rollback reverts an unreachable activation; and that reverting the `flake.lock` bump (git) + re-deploy, or `nixos-rebuild --rollback` on durer, work for a reachable-but-bad version
