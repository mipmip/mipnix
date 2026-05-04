## ADDED Requirements

### Requirement: Nginx enabled on durer
The system SHALL run nginx on durer listening on ports 80 and 443.

#### Scenario: Nginx starts on boot
- **WHEN** durer boots or `nixos-rebuild switch` completes
- **THEN** the `nginx` systemd service SHALL be running and listening on ports 80 and 443

### Requirement: ACME certificate provisioning
The system SHALL use `security.acme` with HTTP-01 challenges to obtain and auto-renew Let's Encrypt certificates for `nuremberg.pimsnel.com`.

#### Scenario: Initial certificate issuance
- **WHEN** the ACME service runs for the first time
- **THEN** a valid TLS certificate for `nuremberg.pimsnel.com` SHALL be provisioned at `/var/lib/acme/nuremberg.pimsnel.com/`

#### Scenario: Certificate auto-renewal
- **WHEN** the certificate approaches expiry
- **THEN** the ACME service SHALL automatically renew it without manual intervention

### Requirement: Health check endpoint
Nginx SHALL serve a minimal static page at `https://nuremberg.pimsnel.com/` that returns HTTP 200 for monitoring purposes.

#### Scenario: Monitoring probe hits health endpoint
- **WHEN** an HTTP GET request is made to `https://nuremberg.pimsnel.com/`
- **THEN** the server SHALL respond with HTTP 200 and a simple page body

### Requirement: HTTP-to-HTTPS redirect
Nginx SHALL redirect all non-ACME HTTP traffic on port 80 to HTTPS on port 443.

#### Scenario: Browser visits HTTP URL
- **WHEN** a client requests `http://nuremberg.pimsnel.com/`
- **THEN** nginx SHALL respond with a 301 redirect to `https://nuremberg.pimsnel.com/`

#### Scenario: ACME challenge request
- **WHEN** Let's Encrypt makes an HTTP-01 challenge request to port 80
- **THEN** nginx SHALL serve the challenge response (not redirect)

### Requirement: Firewall allows HTTP and HTTPS
Ports 80/tcp and 443/tcp SHALL be open in the durer firewall configuration.

#### Scenario: External client reaches HTTPS
- **WHEN** a client from the internet connects to `nuremberg.pimsnel.com:443`
- **THEN** the connection SHALL reach the nginx service

### Requirement: ACME certs accessible to Ergo
The Ergo service user SHALL have read access to the ACME certificate files so it can use them for IRC TLS.

#### Scenario: Ergo reads ACME certs
- **WHEN** the Ergo service starts or reloads
- **THEN** it SHALL be able to read `fullchain.pem` and `key.pem` from `/var/lib/acme/nuremberg.pimsnel.com/`
