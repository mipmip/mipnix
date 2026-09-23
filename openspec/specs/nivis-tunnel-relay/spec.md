# nivis-tunnel-relay Specification

## Purpose
durer serves as the rendezvous point for nivis-tunnel, so that machines with no
inbound port can be reached.

The relay is deliberately incapable: it holds no key material, authenticates
nobody, and cannot read what it carries, because the Noise handshake runs end to
end through it. Those absences are what make hosting one on a machine that also
serves other things a reasonable thing to do.

## Requirements

### Requirement: durer serves rendezvous
durer SHALL run the nivis-tunnel relay and SHALL accept connections to it from
the internet, since both parties to a session dial inward from elsewhere.

#### Scenario: the relay is reachable
- **WHEN** a TCP connection is made to durer on the relay's port from outside
- **THEN** it is accepted

#### Scenario: an agent and an orchestrator are paired
- **GIVEN** an agent on a target announcing a stream id, and an orchestrator announcing the same one
- **WHEN** both have connected
- **THEN** the relay pairs them and bytes flow between them

### Requirement: The relay is the only thing durer gains
Enabling the relay SHALL NOT change any other service on durer, and SHALL open
no port other than the relay's.

durer serves a shop, a database and a nebula lighthouse. A rendezvous service is
worth adding only if it is additive.

#### Scenario: other services are untouched by the deploy
- **WHEN** durer is switched to a configuration that adds the relay
- **THEN** the shop, postgres, docker and nebula continue running, because `switch-to-configuration` restarts only units whose definitions changed

#### Scenario: no other port is opened
- **WHEN** durer's firewall is inspected after the change
- **THEN** the ports open are the ones it had before, plus the relay's, and nothing else
