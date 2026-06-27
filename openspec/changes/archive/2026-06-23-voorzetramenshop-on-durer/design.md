## Context

durer is mipnix's public-facing server. It already runs nginx with ACME/Let's Encrypt (vhosts `pimsnel.com`, `nuremberg.pimsnel.com`), `services.bluesky-pds` (proxied at loopback `:3000`), and Tuwunel Matrix, all assembled via the dendritic pattern under `flake.modules.nixos.durer` across `modules/HOSTS/durer-server/*.nix`. Secrets use agenix (`age.secrets.*` from `secrets/*.age`, recipients declared in `secrets/secrets.nix`).

voorzetramenshop is a Next.js standalone webshop that ships its own NixOS module (`nixosModules.default` → `services.voorzetramenshop`) and, after its merged `nix-package-and-deploy-migrations` change, a runnable package (`packages.<system>.voorzetramenshop`, `node <pkg>/server.js`) bundling the Prisma client + migrations. The module enables PostgreSQL (peer auth over the local socket), runs `prisma migrate deploy` as a oneshot before the app, runs the app as a hardened systemd DynamicUser service reading `EnvironmentFile`, and provisions an nginx vhost + ACME for its `domain`. Login is magic-link only.

The closest in-repo precedent is the archived `bluesky-pds-on-durer` change: a long-running service on durer fed by an agenix env file (`config.age.secrets."personal-data-server-env"`, `publicKeys = [pim durer]`).

### Deployment constraint: durer cannot build the shop locally

durer is a small VM — **30 GB disk, ~15 GB free**. The original plan was to build on durer via `rme up_machine` (sudo `nixos-rebuild switch`). In practice the voorzetramenshop **build** does not fit: building the Next.js app pulls the full `pnpm` `node_modules` (dev deps included), runs the webpack/turbopack compile with `.next/cache`, and drags in the whole nixpkgs build-input chain — several GB of *build-time* artifacts that all overflow durer's disk before any output exists.

Critically, **none of that build garbage is in the runtime closure**. Measured on lego2 (x86_64-linux, matching durer):

| Component | Closure size | Notes |
|---|---|---|
| shop bundle (`packages.x86_64-linux.voorzetramenshop`) | **42.6 MiB**, 1 path | Next.js `standalone` output: `.next` + bundled minimal `node_modules` + `server.js`, **zero** nix store references (self-contained) |
| `nodejs_22` (the runtime interpreter) | **245.6 MiB**, ~57 paths | From `module.nix`: `ExecStart = ${pkgs.nodejs_22}/bin/node ${cfg.package}/server.js` — the interpreter is **not** in the package, the module adds it |
| **union (deduped)** | **~322 MiB, 58 paths** | What `nix copy` transfers on the first deploy |

(`+` PostgreSQL server closure if durer doesn't already run it — still tens of MiB, trivial.)

The lesson: **the thing that overflows durer is the build, not the closure.** The runtime closure is ~322 MiB and fits ~46× over in 15 GB. So the deploy model must be **build on lego2 (882 GB disk, 183 GB free, native x86_64-linux), then `nix copy` only the closure to durer** — build intermediates never touch durer's disk. This is the central design pivot of this change (see the deploy decision below), and it also dissolves the old sudo-strips-the-agent problem, because evaluation now happens as `pim` on lego2 where the SSH agent is native.

durer is reachable from lego2 at the Nebula IP `192.168.100.12` (verified: SSH works, `sudo -n true` succeeds — durer has `security.sudo.wheelNeedsPassword = false`). All of the above was measured/verified live, not estimated.

## Goals / Non-Goals

**Goals:**
- Run voorzetramenshop on durer behind nginx/ACME at `mintshop.nuremberg.pimsnel.com`.
- Deploy by **building on lego2 and copying the closure to durer** (durer cannot build the shop — see the deployment constraint above), using **deploy-rs** with magic rollback, wrapped as `deploy_remote durer` in `RUNME.d/`.
- Keep `flake.lock` (with `voorzetramenshop` pinned) as the version record and rollback point.
- Feed the service its secrets through agenix, matching the existing durer convention.
- Compose cleanly with durer's existing nginx/ACME without disturbing current vhosts.

**Non-Goals:**
- Authoring voorzetramenshop's package or migration logic — that lives upstream and is already merged.
- Selecting/operating an SMTP provider beyond wiring AWS SES SMTP credentials into the env file.
- Setting up unattended/CI rebuilds — deploys are interactive (the build host's SSH agent reaches the private repo).
- Generalising deploy-rs to the rest of the Nebula fleet (harry/hurry/lavendel/dapperehaan) — the `deploy_remote` wrapper takes a host argument so it *can* grow there later, but only durer is wired as a `deploy.nodes` entry here.
- Backup strategy for the PostgreSQL data (noted as a follow-up, not implemented here).

## Decisions

### Decision: Consume the upstream module, not a hand-rolled service
Import `inputs.voorzetramenshop.nixosModules.default` and configure `services.voorzetramenshop`, mirroring how `services.bluesky-pds` is used. The module is the supported integration surface and owns DB, migrations, hardening, and the nginx vhost.
- **Alternative considered**: build the package as a flake output and write our own systemd unit + nginx vhost (like `pimsnel-website`'s nginx `root`). Rejected — voorzetramenshop is a stateful long-running service with migrations; re-implementing the module's hardening/migration ordering would be duplicative and fragile.

### Decision: Private input over SSH, following nixpkgs
`voorzetramenshop.url = "git+ssh://git@github.com/mintglasinlood/voorzetramenshop.git"` with `inputs.nixpkgs.follows = "nixpkgs"`. This is the first private/`git+ssh` input in the flake (all others are public `github:`). Following nixpkgs keeps the closure on durer's nixos-26.05 and improves cache hits.
- **Alternative considered**: make the repo public (drops the auth problem). Rejected by the user — the repo stays private.
- **Alternative considered**: let the input pin its own nixpkgs. Rejected — diverging nixpkgs bloats the closure; revisit only if a build break shows the package needs a newer nixpkgs.

### Decision: Build on lego2 and deploy to durer with deploy-rs (not `nixos-rebuild` on durer)
durer cannot hold the shop's multi-GB *build* footprint (see the deployment constraint in Context). So the system closure for `nixosConfigurations.durer` is built on **lego2** (native x86_64-linux, 183 GB free) and only the realised closure (~322 MiB for the shop+node delta, plus the normal channel-bump delta) is `nix copy`-ed to durer; activation runs remotely over passwordless sudo. We use **deploy-rs** rather than a bare `nixos-rebuild --target-host` because durer is a headless, remote box reached only over Nebula: deploy-rs's **magic rollback** auto-reverts to the previous generation if durer fails to confirm reachability after activation, which a bad switch that kills SSH would otherwise leave unrecoverable without console access.
- deploy-rs is wired as a flake input (`inputs.deploy-rs`, `inputs.nixpkgs.follows = "nixpkgs"`) plus a top-level `flake.deploy.nodes.durer` set via flake-parts' `flake.deploy = { … }` escape hatch (flake-parts has no native `deploy` option; it is not a `perSystem` output). `deploy.nodes.durer` points `profiles.system.path` at `inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.durer` — **durer's host config is unchanged** apart from the trusted-users fix below.
- **Alternative considered**: `nixos-rebuild switch --flake .#durer --build-host "" --target-host pim@durer --use-remote-sudo`. Zero new dependency and solves the disk problem identically, but no automatic rollback. Rejected for a remote box; kept documented as the fallback if deploy-rs is unavailable.
- **Alternative considered**: colmena (already in lego2's systemPackages). Viable, but its rollback story is weaker than deploy-rs's magic rollback.
- **Private fetch**: building on lego2 removes the old "sudo strips `SSH_AUTH_SOCK`" failure — `deploy .#durer` evaluates as `pim`, where the agent is native, so the private `voorzetramenshop` fetch succeeds. The only surviving discipline is to run `nix flake update voorzetramenshop` (as `pim`, agent live) **before** deploying, so deploy-rs evaluates an already-locked input. **This lock-then-deploy order is load-bearing.**

### Decision: Add `pim` to durer's nix `trusted-users` (the one durer-side change)
deploy-rs pushes via `ssh-ng://` by default, which copies into durer's nix daemon. durer currently has `trusted-users = root` only (inherited default). A closure built on lego2 is **unsigned** (lego2 is not a trusted signing key durer knows), and pushing an unsigned path as a non-trusted user is rejected — verified live:

```
error: cannot add path '/nix/store/…' because it lacks a signature by a trusted key
```

Fix: `nix.settings.trusted-users = [ "root" "pim" ];` on durer (one line, in the durer module). This is the single exception to "durer's config is unchanged."
- **Alternative considered**: sign lego2's store and add its public key to durer's `trusted-public-keys`. More "correct" (paths verifiable, works for any pusher) but more setup; deferred — revisit if more than one machine ever deploys to durer.
- **Alternative considered**: force plain `ssh://` (copies signed paths via the daemon differently) — verified that an *already-signed* path (e.g. from cache.nixos.org) copies fine as `pim` even today, but locally-built shop paths are unsigned, so this does not help. Rejected.

### Decision: `deploy_remote <host>` wrapper in `RUNME.d/`, run from the build host
A new `make_command "deploy_remote"` in `RUNME.d/` (likely a new `deploy.sh`) wraps the flow. Unlike `up_machine`/`up_home`, which rebuild **the current host** (`$(hostname)`), `deploy_remote` runs on lego2 and targets a **named remote** passed as an argument (`deploy_remote durer`), so it does not use `$(hostname)`. Sketch of the flow it encodes:

```
deploy_remote <host>:
  check_untracked                                  # reuse existing helper
  # (operator runs `nix flake update voorzetramenshop` first when bumping the shop)
  nix run github:serokell/deploy-rs -- .#<host>    # build on lego2, copy closure, activate w/ magic rollback
  if success: EXTRA_ARG="auto run after deploy_remote <host>"; git_sync_machine   # commit+tag on lego2
  else: report failure (deploy-rs has already auto-rolled-back durer); exit 1
```

It reuses `check_untracked` and `git_sync_machine` exactly as the `up_*` commands do. `git_sync_machine` tags with `$(hostname)` (= lego2, the machine the deploy was *driven from*), which is acceptable — the tag records "lego2 deployed this revision."

### Decision: Garbage-collection policy on durer (keep rollback, bound the disk)
With only ~15 GB free, durer must prune old generations, but **not** before deploy-rs confirms the new generation is healthy (magic rollback needs the previous generation intact during the confirmation window). So GC is *not* part of `deploy_remote`'s happy path. Policy: cap retained generations via `boot.loader.grub.configurationLimit` (durer uses GRUB) and/or a periodic `nix.gc` timer with `options = "--delete-older-than 14d"`, both in durer's config. The deploy itself never GCs.
- **Alternative considered**: GC immediately after a successful switch inside `deploy_remote`. Rejected — races with the magic-rollback confirmation window and removes the rollback target.

### Decision: Single agenix secret, recipients `[ pim durer ]`, rely on root-read of EnvironmentFile
Add `secrets/voorzetramenshop-env.age` with `publicKeys = [ pim durer ]` (edit-time = pim, runtime = durer host key), exactly like `personal-data-server.env.age`. Wire `environmentFile = config.age.secrets."voorzetramenshop-env".path`. Keep agenix defaults (`root:root`, `0400`): systemd reads `EnvironmentFile=` as PID 1 before dropping to the DynamicUser, and the migrate oneshot does the same, so neither unit's runtime identity needs to be a decryption recipient or have file read access.
- **Alternative considered**: a shared group + `0440` so a DynamicUser could read the file directly. Held as a fallback **only if** verification shows the module reads the env file via a script running as the unprefixed user rather than via `EnvironmentFile=`.

### Decision: Let the module own nginx/ACME composition
The module sets `services.nginx.enable`, a new vhost, `security.acme.acceptTerms`, and a default email via `lib.mkDefault`. durer sets `services.nginx.enable` and `security.acme.defaults.email = "pim@pimsnel.com"` without `mkDefault`, so durer wins. The new vhost key (`mintshop.nuremberg.pimsnel.com`) is distinct from existing keys, and `*.nuremberg.pimsnel.com` DNS lets per-host HTTP-01 issuance succeed without a wildcard cert.

## Risks / Trade-offs

- **Magic-link is the only auth + launch is gated behind `maintenanceMode`** → If SES isn't sending, *nobody* (including admin) can log in. Mitigation: verify SES is out of sandbox (or the admin recipient is verified) and that a test magic-link is received before announcing.
- **SES SMTP password is not the AWS Secret Access Key** → It's a region-specific *derived* value, and being base64 it often contains `/ + =` that must be URL-encoded inside the `smtp://` URL. A wrong value yields silent `535` auth failures. Mitigation: derive via SES "Create SMTP credentials", URL-encode, note in the launch checklist.
- **DynamicUser cannot read the secret directly** → If the upstream module reads the env file as the service user instead of via `EnvironmentFile=`, the root-only `0400` file fails. Mitigation: read the module source after adding the input; fall back to a shared group + `0440` if needed.
- **Private input fetch under the wrong identity** → Deploying without the SSH agent (or with a stale lock requiring a network fetch under the wrong identity) breaks the private fetch. Mitigation: building on lego2 means evaluation runs as `pim` (agent native); keep the lock-then-deploy order so deploy-rs evaluates an already-locked input.
- **Unsigned closure rejected by durer (`ssh-ng`)** → **Confirmed live**: deploy-rs's default `ssh-ng://` push of a lego2-built (unsigned) path fails with `lacks a signature by a trusted key` while `trusted-users = root` only. Mitigation: add `pim` to durer's `trusted-users` (a planned task, not a surprise).
- **15 GB free is tight for two closures during activation** → Activation briefly holds old+new system closures on durer. The shop+node delta is only ~322 MiB, so this fits comfortably, but a long-neglected durer (many stale generations) could drift toward full. Mitigation: the GC policy (configurationLimit + periodic `nix.gc`); magic rollback constrains *when* GC may run.
- **The shop has never actually built** → The input is still commented out and the change sits at 8/23 tasks; the first real Next.js build (now on lego2) may surface nixpkgs/build issues. This is orthogonal to deploy-rs — deploy-rs only moves *where* the build runs. Mitigation: a `nix build .#nixosConfigurations.durer.config.system.build.toplevel` gate on lego2 before the first deploy; building on the big disk is exactly what unblocks this.
- **flake-parts has no native `deploy` output** → `flake.deploy` is set via flake-parts' arbitrary-top-level escape hatch and must not be a `perSystem` output. Mitigation: documented in the deploy decision; `deploy-rs.lib.<sys>.deployChecks` merges with the existing `checks.mipvim` under `nix flake check`.
- **nixpkgs.follows could break the build** → If the package depends on a newer nixpkgs than 26.05. Mitigation: caught at the first `nix build` on lego2; revert to the input's own nixpkgs if so.
- **Upstream contract drift** → The change designs against `nixosModules.default` + `packages.<system>.voorzetramenshop`. Mitigation: `nix flake show` gate before deploy.

## Migration Plan

Run all steps **on lego2** (the build host), from `~/mipnix`, with the SSH agent loaded.

1. Land this change in mipnix: `voorzetramenshop` input, durer module import + service config, agenix secret entry, **`deploy-rs` input**, **`flake.deploy.nodes.durer`** module, **durer `trusted-users += pim`** + **GC policy**, and the **`deploy_remote` RUNME.d wrapper**. The `.age` file is already authored by the user.
2. `nix flake update voorzetramenshop` (as `pim`, agent live) — locks the revision, fetches privately.
3. `nix flake show 'git+ssh://…/voorzetramenshop'` (or the locked input) confirms `nixosModules.default` and `packages.<system>.voorzetramenshop`.
4. Gate the build: `nix build .#nixosConfigurations.durer.config.system.build.toplevel` on lego2 — proves the (large) shop build succeeds on the big disk before anything touches durer.
5. `rme deploy_remote durer` — deploy-rs builds on lego2, `nix copy`s the closure to durer, activates over passwordless sudo, and magic-rolls-back if durer doesn't confirm reachability.
6. Verify: migrate oneshot succeeded, app listening on `127.0.0.1:3001`, ACME cert issued for `mintshop.nuremberg.pimsnel.com`, existing vhosts still serve, a magic-link email is received and login works.
7. **Rollback**: deploy-rs auto-reverts a failed/unreachable activation. For a *bad-but-reachable* version, revert the `flake.lock` bump (git) and re-deploy, or `nixos-rebuild --rollback` on durer.

## Open Questions

- Does the upstream module read the env file via `EnvironmentFile=` only (expected), or also via a user-run script? Resolve by reading the module source before the deploy.
- Exact GC tuning: `boot.loader.grub.configurationLimit` value and whether to add a `nix.gc` timer vs. rely on generation cap, given 15 GB and the shop's ~322 MiB delta.
- Backup/retention policy for the `voorzetramenshop` PostgreSQL database — out of scope here, worth a follow-up.
- Whether to later generalise `deploy_remote` + `deploy.nodes` to the rest of the Nebula fleet (the wrapper already takes a host argument).

## Troubleshooting

### deploy-rs push fails: `lacks a signature by a trusted key` (CONFIRMED)

**Symptom**: `deploy_remote durer` aborts during the copy with `error: cannot add path '/nix/store/…' because it lacks a signature by a trusted key`.

**Root cause**: deploy-rs pushes via `ssh-ng://` into durer's nix daemon. The closure was built on lego2 and is unsigned; durer's `trusted-users` is `root` only, so `pim` may not add unsigned paths. Verified live during exploration.

**Solution**: add `pim` to durer's nix trusted users (a task in this change):

```nix
nix.settings.trusted-users = [ "root" "pim" ];
```

Re-deploy after the durer config carries this (note: it must be activated on durer once via the fallback `--target-host` path or an in-session rebuild before the *first* deploy-rs push, or applied while `root` is still the pushing identity — chicken-and-egg; see task notes).

### Private input fails to fetch during deploy (`Permission denied (publickey)`)

**Symptom**: `deploy_remote durer` aborts with `error: Failed to fetch git repository 'ssh://git@github.com/mintglasinlood/voorzetramenshop.git'` / `Permission denied (publickey)`.

**Root cause**: evaluation could not reach the private repo — either the SSH agent isn't loaded on lego2, or the `flake.lock` is stale and a network fetch happened under the wrong identity. Building on lego2 (as `pim`) is specifically meant to avoid the old sudo-strips-the-agent failure.

**Solution**: ensure the agent is loaded on lego2 and the lock is current before deploying:

```fish
cd ~/mipnix
ssh-add -l                             # agent has a key with mintglasinlood access
nix flake update voorzetramenshop      # as pim — fetches + writes flake.lock
rme deploy_remote durer                # deploy-rs reads the already-locked store path
```

**Lock-then-deploy order is load-bearing** — bump the lock as `pim` first, then deploy.

### URL format gotchas (not #3503)

- Use the flake scheme **`git+ssh://git@github.com/owner/repo.git`** (slash separators).
- `ssh://git@github.com/owner/repo.git` → `error: input … is unsupported` (missing `git+` prefix).
- `git@github.com:owner/repo.git` (scp/colon form) → not a valid flake URL.
- nix issue **#3503** (scp-form wrongly prefixed with `file://`) was fixed in nix 2.4; it does not apply to nix ≥ 2.4 (durer/this repo run far newer).
- If a "`using 'master'`" / missing-ref error persists *after* auth works, the repo's default branch is likely `main` — pin it: `…/voorzetramenshop.git?ref=main`.
