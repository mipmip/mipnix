## ADDED Requirements

### Requirement: Nginx proxies Matrix client API
Nginx SHALL proxy all requests to `/_matrix/` on `nuremberg.pimsnel.com:443` to the Tuwunel service on `localhost:6167`.

#### Scenario: Matrix client connects
- **WHEN** a Matrix client sends a request to `https://nuremberg.pimsnel.com/_matrix/client/v3/login`
- **THEN** nginx SHALL proxy the request to `http://localhost:6167/_matrix/client/v3/login` and return the response

### Requirement: Well-known Matrix server delegation
Nginx SHALL serve `/.well-known/matrix/server` returning the server address for federation discovery.

#### Scenario: Federation discovery request
- **WHEN** a client or server requests `https://nuremberg.pimsnel.com/.well-known/matrix/server`
- **THEN** nginx SHALL respond with JSON containing `{"m.server": "nuremberg.pimsnel.com:443"}`

### Requirement: Well-known Matrix client configuration
Nginx SHALL serve `/.well-known/matrix/client` returning the homeserver base URL for client discovery.

#### Scenario: Client discovery request
- **WHEN** a Matrix client requests `https://nuremberg.pimsnel.com/.well-known/matrix/client`
- **THEN** nginx SHALL respond with JSON containing the homeserver base URL `https://nuremberg.pimsnel.com` and appropriate CORS headers

### Requirement: Request size limit
Nginx SHALL allow request bodies up to 20 MB to match Tuwunel's `max_request_size` for file uploads.

#### Scenario: Large file upload
- **WHEN** a client uploads a file up to 20 MB via the Matrix media API
- **THEN** nginx SHALL proxy the request without rejecting it for size
