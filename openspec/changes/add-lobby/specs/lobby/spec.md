## Purpose

Give one place, in the browser and in the terminal, that shows where every
service runs, how it is reached and where it is configured in mipnix.

## ADDED Requirements

### Requirement: Services are registered next to their configuration

The flake SHALL provide a `lobby.services` registry whose entries have
a title, description, host, URL (or none), access type (`nebula`, `lan`,
`public`, `tunnel` or `local`) and category. Entries SHALL be defined in the
module that configures the service, and the registry SHALL be readable
without evaluating any host configuration.

#### Scenario: Adding a service

- **WHEN** a module adds an entry to `lobby.services` and the flake is
  rebuilt
- **THEN** the service appears on the page and in the CLI without any other
  change

#### Scenario: Invalid access type

- **WHEN** an entry sets an access type outside the allowed set
- **THEN** evaluation fails with a message naming the entry

### Requirement: Each entry knows where it is defined

Each service SHALL carry the repository-relative file and line where its
entry is defined, determined by Nix, not written by hand.

#### Scenario: Source shown

- **WHEN** the Grafana entry is defined in
  `modules/services/monitoring/grafana.nix`
- **THEN** its source is shown as that path with the line of the entry

### Requirement: One generated JSON contract

The build SHALL produce one JSON file containing the services and a
`generated` block with the mipnix revision and date, in the shape documented
in the design. The page and the CLI SHALL both read this file.

#### Scenario: Revision recorded

- **WHEN** lobby is built from commit `abc1234`
- **THEN** the JSON's `generated.commit` is `abc1234`

#### Scenario: Unsafe characters

- **WHEN** a description contains `</script>`
- **THEN** the page still renders and the text is shown literally

### Requirement: Web page at http://lobby/ over nebula

dapperehaan SHALL serve the lobby page at `http://lobby/`, listening on its
nebula address only. Every mesh member SHALL resolve `lobby` to that address.
The page SHALL follow the design handoff and SHALL load no resources from the
internet.

#### Scenario: Opening the page

- **WHEN** pim opens `http://lobby/` on a mesh member
- **THEN** every registered service is listed, grouped by category, with
  host, access badge, URL and source

#### Scenario: Filtering

- **WHEN** pim types a host name in the filter box or clicks a host button
- **THEN** only that host's services remain visible

#### Scenario: Outside the mesh

- **WHEN** a device on the LAN without nebula requests port 80 on
  dapperehaan's LAN address
- **THEN** the lobby page is not served

#### Scenario: Phone width

- **WHEN** the page is viewed 390 pixels wide
- **THEN** rows stack into cards and there is no horizontal scrolling

### Requirement: lobby command

A `lobby` command SHALL be on the PATH of pim's machines, with the registry
built in so it works without network access to dapperehaan. It SHALL list
services grouped by category, show one service in full, open a service's URL
in the browser, and print the registry as JSON.

#### Scenario: Listing

- **WHEN** pim runs `lobby`
- **THEN** services are printed grouped by category with key, host, access
  and URL, sorted as on the page

#### Scenario: Opening

- **WHEN** pim runs `lobby open grafana`
- **THEN** the Grafana URL opens in the default browser

#### Scenario: Unknown name

- **WHEN** pim runs `lobby open grafan`
- **THEN** the command exits with status 1 and suggests `grafana`

#### Scenario: No web UI

- **WHEN** pim runs `lobby open samba`
- **THEN** the command exits with status 1 and says samba has no web UI

#### Scenario: Piped output

- **WHEN** the output of `lobby` is piped
- **THEN** it contains no colour codes and no picker is started

### Requirement: Current services are registered

The registry SHALL contain the services running at the time of this change:
Grafana, Prometheus, Backrest, linny-mcp (if confirmed), Samba, Syncthing,
Immich, Uptime Kuma, Vaultwarden, Tuwunel, umami, voorzetramenshop, the
studio-mint and pimsnel.com sites, and piethein's DSM.

#### Scenario: First version complete

- **WHEN** lobby is first deployed
- **THEN** each of these services appears with a working URL or "no web UI"
