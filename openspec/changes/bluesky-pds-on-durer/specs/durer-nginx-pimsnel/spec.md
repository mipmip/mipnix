## ADDED Requirements

### Requirement: Nginx vhost for pimsnel.com
Nginx SHALL serve `pimsnel.com` on ports 80 and 443 with ACME/Let's Encrypt TLS.

#### Scenario: HTTPS available
- **WHEN** a client connects to `https://pimsnel.com/`
- **THEN** nginx SHALL present a valid Let's Encrypt certificate

### Requirement: PDS reverse proxy
Nginx SHALL proxy AT Protocol requests on `pimsnel.com` to the PDS on port 3000.

#### Scenario: XRPC requests proxied
- **WHEN** a client sends a request to `https://pimsnel.com/xrpc/*`
- **THEN** nginx SHALL proxy the request to `http://localhost:3000`

#### Scenario: Well-known requests proxied
- **WHEN** a client requests `https://pimsnel.com/.well-known/atproto-did`
- **THEN** nginx SHALL proxy the request to `http://localhost:3000`

### Requirement: WebSocket support
Nginx SHALL forward WebSocket upgrade headers for PDS streaming connections.

#### Scenario: WebSocket connection
- **WHEN** a client initiates a WebSocket upgrade to `pimsnel.com/xrpc/*`
- **THEN** nginx SHALL forward the Upgrade and Connection headers to the PDS

### Requirement: Blob upload size
Nginx SHALL allow request bodies up to 100 MB on the pimsnel.com vhost to support PDS blob uploads.

#### Scenario: Large image upload
- **WHEN** a user uploads a file up to 100 MB via the PDS
- **THEN** nginx SHALL proxy the request without rejecting it for size
