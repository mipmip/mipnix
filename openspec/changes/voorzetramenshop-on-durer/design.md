## Context

durer is mipnix's public-facing server. It already runs nginx with ACME/Let's Encrypt (vhosts `pimsnel.com`, `nuremberg.pimsnel.com`), `services.bluesky-pds` (proxied at loopback `:3000`), and Tuwunel Matrix, all assembled via the dendritic pattern under `flake.modules.nixos.durer` across `modules/HOSTS/durer-server/*.nix`. Secrets use agenix (`age.secrets.*` from `secrets/*.age`, recipients declared in `secrets/secrets.nix`).

voorzetramenshop is a Next.js standalone webshop that ships its own NixOS module (`nixosModules.default` → `services.voorzetramenshop`) and, after its merged `nix-package-and-deploy-migrations` change, a runnable package (`packages.<system>.voorzetramenshop`, `node <pkg>/server.js`) bundling the Prisma client + migrations. The module enables PostgreSQL (peer auth over the local socket), runs `prisma migrate deploy` as a oneshot before the app, runs the app as a hardened systemd DynamicUser service reading `EnvironmentFile`, and provisions an nginx vhost + ACME for its `domain`. Login is magic-link only.

The closest in-repo precedent is the archived `bluesky-pds-on-durer` change: a long-running service on durer fed by an agenix env file (`config.age.secrets."personal-data-server-env"`, `publicKeys = [pim durer]`).

## Goals / Non-Goals

**Goals:**
- Run voorzetramenshop on durer behind nginx/ACME at `mintshop.nuremberg.pimsnel.com`.
- Deploy new versions with `nix flake update voorzetramenshop` + `rme up_machine`, with `flake.lock` as the version record and rollback point.
- Feed the service its secrets through agenix, matching the existing durer convention.
- Compose cleanly with durer's existing nginx/ACME without disturbing current vhosts.

**Non-Goals:**
- Authoring voorzetramenshop's package or migration logic — that lives upstream and is already merged.
- Selecting/operating an SMTP provider beyond wiring AWS SES SMTP credentials into the env file.
- Setting up unattended/CI rebuilds — deploys are interactive (`ssh -A` agent forwarding).
- Backup strategy for the PostgreSQL data (noted as a follow-up, not implemented here).

## Decisions

### Decision: Consume the upstream module, not a hand-rolled service
Import `inputs.voorzetramenshop.nixosModules.default` and configure `services.voorzetramenshop`, mirroring how `services.bluesky-pds` is used. The module is the supported integration surface and owns DB, migrations, hardening, and the nginx vhost.
- **Alternative considered**: build the package as a flake output and write our own systemd unit + nginx vhost (like `pimsnel-website`'s nginx `root`). Rejected — voorzetramenshop is a stateful long-running service with migrations; re-implementing the module's hardening/migration ordering would be duplicative and fragile.

### Decision: Private input over SSH, following nixpkgs
`voorzetramenshop.url = "git+ssh://git@github.com/mintglasinlood/voorzetramenshop.git"` with `inputs.nixpkgs.follows = "nixpkgs"`. This is the first private/`git+ssh` input in the flake (all others are public `github:`). Following nixpkgs keeps the closure on durer's nixos-26.05 and improves cache hits.
- **Alternative considered**: make the repo public (drops the auth problem). Rejected by the user — the repo stays private.
- **Alternative considered**: let the input pin its own nixpkgs. Rejected — diverging nixpkgs bloats the closure; revisit only if a build break shows the package needs a newer nixpkgs.

### Decision: Auth via SSH agent forwarding, with a deliberate two-step deploy
The fetch must happen as the user (agent available), not under sudo. `sudo nixos-rebuild` strips `SSH_AUTH_SOCK`, so a private fetch during the privileged build would fail. Running `nix flake update voorzetramenshop` first (as the user) writes `flake.lock` and pulls the input into the store; the later `rme up_machine` only reads the locked store path. **Order is load-bearing.**
- **Alternative considered**: a read-only deploy key on durer (works unattended). Deferred — the user chose agent forwarding; a deploy key can be added later if automated rebuilds are wanted.

### Decision: Single agenix secret, recipients `[ pim durer ]`, rely on root-read of EnvironmentFile
Add `secrets/voorzetramenshop-env.age` with `publicKeys = [ pim durer ]` (edit-time = pim, runtime = durer host key), exactly like `personal-data-server.env.age`. Wire `environmentFile = config.age.secrets."voorzetramenshop-env".path`. Keep agenix defaults (`root:root`, `0400`): systemd reads `EnvironmentFile=` as PID 1 before dropping to the DynamicUser, and the migrate oneshot does the same, so neither unit's runtime identity needs to be a decryption recipient or have file read access.
- **Alternative considered**: a shared group + `0440` so a DynamicUser could read the file directly. Held as a fallback **only if** verification shows the module reads the env file via a script running as the unprefixed user rather than via `EnvironmentFile=`.

### Decision: Let the module own nginx/ACME composition
The module sets `services.nginx.enable`, a new vhost, `security.acme.acceptTerms`, and a default email via `lib.mkDefault`. durer sets `services.nginx.enable` and `security.acme.defaults.email = "pim@pimsnel.com"` without `mkDefault`, so durer wins. The new vhost key (`mintshop.nuremberg.pimsnel.com`) is distinct from existing keys, and `*.nuremberg.pimsnel.com` DNS lets per-host HTTP-01 issuance succeed without a wildcard cert.

## Risks / Trade-offs

- **Magic-link is the only auth + launch is gated behind `maintenanceMode`** → If SES isn't sending, *nobody* (including admin) can log in. Mitigation: verify SES is out of sandbox (or the admin recipient is verified) and that a test magic-link is received before announcing.
- **SES SMTP password is not the AWS Secret Access Key** → It's a region-specific *derived* value, and being base64 it often contains `/ + =` that must be URL-encoded inside the `smtp://` URL. A wrong value yields silent `535` auth failures. Mitigation: derive via SES "Create SMTP credentials", URL-encode, note in the launch checklist.
- **DynamicUser cannot read the secret directly** → If the upstream module reads the env file as the service user instead of via `EnvironmentFile=`, the root-only `0400` file fails. Mitigation: read the module source after adding the input; fall back to a shared group + `0440` if needed.
- **Private input fetch under the wrong identity** → Running the update under sudo (or without a forwarded agent) breaks the fetch. Mitigation: documented two-step order; `flake.lock` already populated means the rebuild needs no network for this input.
- **nixpkgs.follows could break the build** → If the package depends on a newer nixpkgs than 26.05. Mitigation: caught at first `nix build`/rebuild; revert to the input's own nixpkgs if so.
- **Upstream contract drift** → The change designs against `nixosModules.default` + `packages.<system>.voorzetramenshop`. Mitigation: `nix flake show` gate before rebuild.

## Migration Plan

1. Land this change in mipnix (input + module import + service config + agenix secret entry). The `.age` file is already authored by the user.
2. On durer (with forwarded agent): `cd ~/mipnix && nix flake update voorzetramenshop`.
3. `nix flake show 'git+ssh://…/voorzetramenshop'` (or the locked input) confirms `nixosModules.default` and `packages.<system>.voorzetramenshop`.
4. `rme up_machine` (sudo `nixos-rebuild switch`).
5. Verify: migrate oneshot succeeded, app listening on `127.0.0.1:3001`, ACME cert issued for `mintshop.nuremberg.pimsnel.com`, a magic-link email is received and login works.
6. **Rollback**: revert the `flake.lock` bump in git and rebuild, or `nixos-rebuild --rollback` on durer.

## Open Questions

- Does the upstream module read the env file via `EnvironmentFile=` only (expected), or also via a user-run script? Resolve by reading the module source before the rebuild.
- Backup/retention policy for the `voorzetramenshop` PostgreSQL database — out of scope here, worth a follow-up.
- Whether to later add a read-only deploy key on durer to enable unattended rebuilds.

## Troubleshooting

### Private input fails to fetch during rebuild (`Permission denied (publickey)`)

**Symptom**: `nixos-rebuild`/`rme up_machine` aborts with `error: Failed to fetch git repository 'ssh://git@github.com/mintglasinlood/voorzetramenshop.git'`, and the real cause buried above it is `git@github.com: Permission denied (publickey)`.

**Root cause**: the rebuild runs as **root** (via sudo), and sudo strips `SSH_AUTH_SOCK`, so root has no SSH agent and cannot authenticate to the private repo. The fetch of a flake input happens during evaluation, so it fails before any build starts. This is **not** a nix bug.

**Solution — split the two steps by user**:

```fish
# 1. As pim (SSH agent available — load the key / use `ssh -A` when on durer)
cd ~/mipnix
nix flake update voorzetramenshop      # fetches + writes flake.lock + populates the nix store

# 2. As root (no agent needed — reads the already-locked store path, no network fetch)
rme up_machine                         # i.e. sudo nixos-rebuild switch
```

The locking/fetch in step 1 runs under pim's identity (agent live), so auth succeeds; step 2 only needs the store path that step 1 already produced, so the missing agent under sudo is irrelevant. **Order is load-bearing** — never run `nix flake update` under sudo.

### URL format gotchas (not #3503)

- Use the flake scheme **`git+ssh://git@github.com/owner/repo.git`** (slash separators).
- `ssh://git@github.com/owner/repo.git` → `error: input … is unsupported` (missing `git+` prefix).
- `git@github.com:owner/repo.git` (scp/colon form) → not a valid flake URL.
- nix issue **#3503** (scp-form wrongly prefixed with `file://`) was fixed in nix 2.4; it does not apply to nix ≥ 2.4 (durer/this repo run far newer).
- If a "`using 'master'`" / missing-ref error persists *after* auth works, the repo's default branch is likely `main` — pin it: `…/voorzetramenshop.git?ref=main`.
