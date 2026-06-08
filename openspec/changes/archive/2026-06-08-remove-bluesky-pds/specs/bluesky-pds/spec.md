# Bluesky PDS

## REMOVED Requirements

### Requirement: bluesky-pds-on-durer

**Reason**: The PDS was never used (no account, handle, or atproto identity created on it)
and is not important enough to maintain. Removing it reduces durer's footprint and attack
surface.

**Migration**: None required — no data, accounts, or external identities exist on the PDS.
The `services.bluesky-pds` configuration, its agenix secret (`personal-data-server-env`,
including the `.age` file), and its nginx atproto endpoints are removed; any orphaned
on-disk PDS state directory on durer is deleted at deploy time. To restore in the future,
re-add the upstream `services.bluesky-pds` service and regenerate the secret.

The removed requirement previously stated: durer SHALL run a Bluesky Personal Data Server
via `services.bluesky-pds` with `PDS_HOSTNAME = "pimsnel.com"`, fed by the
`personal-data-server-env` secret, and SHALL expose atproto endpoints (`/xrpc/`,
`/.well-known/atproto-did`) via the `pimsnel.com` nginx vhost.
