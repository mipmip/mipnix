## MODIFIED Requirements

### Requirement: Guest has outbound internet access
The guest SHALL have outbound network connectivity via a TAP interface with NAT on the host. The guest SHALL be able to reach external HTTPS endpoints.

#### Scenario: Outbound HTTPS connectivity
- **WHEN** `curl https://api.openai.com` is run inside the guest
- **THEN** the request SHALL receive an HTTP response (not a connection error)

#### Scenario: Outbound Matrix connectivity
- **WHEN** `curl https://nuremberg.pimsnel.com` is run inside the guest
- **THEN** the request SHALL receive an HTTP response
