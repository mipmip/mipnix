# Durer Nginx pimsnel.com

## MODIFIED Requirements

### Requirement: pimsnel-com-vhost

The `pimsnel.com` nginx virtual host on durer SHALL serve the static website over ACME
HTTPS. It SHALL NOT proxy any Bluesky PDS / atproto endpoints.

#### Scenario: website served over HTTPS

- **WHEN** a client requests `https://pimsnel.com/`
- **THEN** nginx SHALL serve the `pimsnel-website` static content over a valid ACME
  certificate with `forceSSL`

#### Scenario: atproto endpoints removed

- **WHEN** a client requests `https://pimsnel.com/xrpc/...` or
  `https://pimsnel.com/.well-known/atproto-did`
- **THEN** the vhost SHALL NOT proxy these to a PDS backend (the PDS proxy locations are
  removed), and the website vhost SHALL otherwise remain intact

#### Scenario: other durer services unaffected

- **WHEN** the PDS is removed
- **THEN** the `nuremberg.pimsnel.com` vhost, Tuwunel Matrix, and all other durer services
  SHALL continue to function unchanged
