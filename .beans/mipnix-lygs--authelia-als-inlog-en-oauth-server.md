---
# mipnix-lygs
title: Authelia als inlog- en OAuth-server
status: draft
type: feature
created_at: 2026-11-03T21:42:24Z
updated_at: 2026-11-03T21:42:24Z
---

Authelia installeren als centrale inlogserver (OIDC/OAuth 2) en forward-auth
voor web-UI's.

Eerste afnemer: hermes-mcp (change add-hermes-mcp). Die gebruikt nu een vast
bearer-token via de "Request headers"-bèta van Claude custom connectors. Met
Authelia kan de connector naar OAuth:

- Authelia ondersteunt (voor zover bekend, december 2025) geen Dynamic Client
  Registration (RFC 7591). In het connector-venster van Claude "Use your own
  OAuth client" kiezen, met een vooraf in Authelia geregistreerde client.
- Redirect-URI voor claude.ai, desktop en mobiel:
  https://claude.ai/api/mcp/auth_callback. Claude Code gebruikt een loopback
  redirect op een willekeurige poort.
- PKCE S256 is verplicht en wordt door Authelia ondersteund. JWT access tokens
  (RFC 9068) laten hermes-mcp lokaal valideren.
- hermes-mcp moet dan een 401 met `resource_metadata` geven en
  `/.well-known/oauth-protected-resource` serveren met Authelia als issuer.
- De inlogpagina moet bereikbaar zijn voor de telefoon en de token-endpoint
  voor Anthropic (160.79.104.0/21). De IP-allowlist op durer geldt dan niet
  voor Authelia zelf.

Andere kandidaten: forward-auth voor web-UI's die publiek moeten worden.

Bronnen: https://claude.com/docs/connectors/building/authentication.md en
https://claude.com/docs/connectors/custom
