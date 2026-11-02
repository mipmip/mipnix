## ADDED Requirements

### Requirement: Public services are checked over HTTPS

Prometheus SHALL check `https://umami.pimsnel.com` and
`https://studio-mint.shop` at least every minute through a blackbox exporter
on dapperehaan, recording whether the request succeeded, the status code,
the response time and the expiry of the TLS certificate.

#### Scenario: Site answers

- **WHEN** umami responds with HTTP 200
- **THEN** its probe reports success with the response time and certificate
  expiry

#### Scenario: Site down

- **WHEN** studio-mint.shop does not respond or returns an error status
- **THEN** its probe reports failure within two minutes

### Requirement: Core vitals dashboard

Grafana SHALL provide a provisioned "Core vitals" dashboard with a tile per
core host (durer, harry, hurry, dapperehaan, piethein, peterspav), tiles for
umami and studio-mint.shop, and one tile for all backups. Each tile SHALL be
green when healthy and red or orange otherwise.

#### Scenario: Host down

- **WHEN** hurry stops answering scrapes
- **THEN** the hurry tile turns red

#### Scenario: Degraded RAID

- **WHEN** piethein answers but a RAID or storage pool is not normal
- **THEN** the piethein tile turns red

#### Scenario: Certificate close to expiry

- **WHEN** the certificate of umami expires in less than 14 days
- **THEN** the umami tile turns orange, and red below 3 days

#### Scenario: Backup failed

- **WHEN** any restic backup or `hip-repo-backup` unit is failed, or a
  backup timer has not fired for more than 26 hours
- **THEN** the backups tile turns red and shows how many

### Requirement: Host summary dashboard

Grafana SHALL provide a provisioned "Host summary" dashboard with one row
per host showing Nix system generations, root disk size and free space,
uptime, memory used and total, swap used and total, and number of CPU cores.
piethein SHALL appear with the values its SNMP metrics provide.

#### Scenario: Comparing hosts

- **WHEN** pim opens Host summary
- **THEN** every monitored host is listed with all columns filled where the
  host reports the value

#### Scenario: piethein row

- **WHEN** the table shows piethein
- **THEN** its volume size and free space, uptime, memory, swap and cores
  come from SNMP and its generations column is empty
