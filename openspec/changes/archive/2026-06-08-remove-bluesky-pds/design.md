## Context

`durer` runs a Bluesky PDS via the upstream nixpkgs `services.bluesky-pds`, wired in
`modules/HOSTS/durer-server/configuration.nix`:

- `services.bluesky-pds` with `PDS_HOSTNAME = "pimsnel.com"`, fed by an agenix secret.
- `age.secrets."personal-data-server-env"` (owner/group `pds`), registered in
  `secrets/secrets.nix` and backed by `secrets/personal-data-server.env.age`.
- Two proxy locations on the **shared** `pimsnel.com` nginx vhost: `/xrpc/` and
  `/.well-known/atproto-did`, both forwarding to `localhost:3000`.

The `pimsnel.com` vhost is shared: it also serves the static website (`root = ...
pimsnel-website`) over ACME HTTPS. The PDS was never used (no account/handle/identity), so
removal has no external or data-value consequences.

The original add-change `bluesky-pds-on-durer` is still active (never archived) and defined
two capabilities: `bluesky-pds` and `durer-nginx-pimsnel`.

## Goals / Non-Goals

**Goals:**
- Remove the PDS service, its secret (fully, including the `.age` file), and its atproto
  nginx endpoints from `durer`.
- Leave the `pimsnel.com` website vhost (root, ACME, SSL) fully intact.
- Clean up orphaned PDS state on the server so "removed" means actually gone.

**Non-Goals:**
- Touching anything else on durer (Matrix/Tuwunel, the `nuremberg.pimsnel.com` vhost,
  Nebula, roles).
- Preserving the PDS secret for later (explicitly a full delete, not dormant).
- DNS changes — `pimsnel.com` and other vhosts serve other services; no atproto-specific
  DNS to undo.
- Archiving the old add-change (separate bookkeeping step).

## Decisions

### Surgical vhost edit — remove only the PDS locations, keep the vhost

The `pimsnel.com` vhost is shared with the website. Remove **only** the `locations."/xrpc/"`
and `locations."/.well-known/atproto-did"` entries; keep `root`, `enableACME`, `forceSSL`,
and the vhost block itself.

**Why**: deleting the whole vhost would take down the website. The PDS only *added*
locations to a pre-existing/shared vhost.

**Risk if done wrong**: treating "remove PDS" as "delete the pimsnel.com block" would break
the site. Called out explicitly so implementation doesn't over-delete.

### Full secret removal (three parts)

Remove all three: the `age.secrets."personal-data-server-env"` block in the host config,
the `"personal-data-server.env.age"` line in `secrets/secrets.nix`, and the `.age` file
itself.

**Why**: user chose a clean slate, not a dormant/restorable secret. Leaving any of the three
behind would be incomplete (dangling registry entry, or an orphaned encrypted file).

**Alternative considered**: unwire but keep the `.age` file dormant for easy re-enable —
rejected per the user's "full delete" choice (PDS was never used; re-adding later would just
regenerate the secret).

### Deploy-time data cleanup

After deploying the config (service removed), manually remove the PDS state directory on
durer (the upstream service's `StateDirectory`/data path under `/var/lib`). NixOS stops and
removes the unit but does not delete its persisted data.

**Why**: otherwise "removed" leaves orphaned data on disk. The exact path is determined on
the server at apply time (inspect the former unit's data dir).

### Capability spec treatment

- `bluesky-pds` → REMOVED capability.
- `durer-nginx-pimsnel` → MODIFIED capability (website + ACME remain; atproto proxy
  locations gone).

Note: neither capability exists in `openspec/specs/` yet (the add-change was never
synced/archived), so the delta specs in this change describe the end state; main-spec sync
happens at archive time.

## Risks / Trade-offs

- **[Risk] Over-deleting the shared vhost** → website outage.
  *Mitigation*: remove only the two PDS `locations`; design + tasks state this explicitly.
- **[Risk] Orphaned on-disk PDS data** → "removed" but cruft remains.
  *Mitigation*: deploy-time cleanup task; determine path on the server.
- **[Risk] agenix rekey** → removing a secret from `secrets.nix` changes the secret set; no
  rekey of *other* secrets is needed, but confirm the build/agenix step is clean after
  removal. Low risk (removal only).

## Migration Plan

1. Remove the `services.bluesky-pds` block, the `age.secrets."personal-data-server-env"`
   block, and the two PDS `locations` from `durer-server/configuration.nix`.
2. Remove the `personal-data-server.env.age` line from `secrets/secrets.nix` and delete the
   `.age` file.
3. Build durer's config; confirm it evaluates and the `pimsnel.com` website vhost is intact.
4. Deploy durer (`up_machine`); confirm the website still serves and the PDS service is gone.
5. On durer, remove the orphaned PDS state directory.

**Rollback**: restore the removed config and the `.age` file (would require re-creating the
secret content, since the file is deleted) and redeploy.

## Open Questions

- Exact on-disk PDS state directory path on durer (determined at apply time from the former
  `services.bluesky-pds` unit's `StateDirectory`).
