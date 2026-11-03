## MODIFIED Requirements

### Requirement: lobby command

A `lobby` command SHALL be on the PATH of pim's machines, with the registry
built in so it works without network access to dapperehaan. It SHALL list
services grouped by category, show one service in full, open a service's URL
in the browser, and print the registry as JSON.

The interactive picker SHALL offer only services that have a URL and are
marked as browsable. A service is browsable unless its registry entry sets
`browse = false`. Listing, showing and the web page SHALL keep every service.

The browser SHALL be started detached from the terminal, so it keeps running
when the terminal or popup that ran `lobby` closes.

#### Scenario: Listing

- **WHEN** pim runs `lobby list`
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

#### Scenario: Picker hides services without a page

- **WHEN** pim runs `lobby` on a terminal
- **THEN** the picker does not offer samba, prometheus, tuwunel or linny-mcp
- **AND** `lobby list` still shows them

#### Scenario: Browser survives the terminal closing

- **WHEN** a service is opened and the terminal that ran `lobby` closes
  straight after
- **THEN** the browser still opens the URL

## ADDED Requirements

### Requirement: lobby in a tmux popup

`prefix + W` SHALL open the `lobby` picker in a tmux popup. The popup SHALL
close by itself once a service has been opened or the picker is cancelled.
The binding SHALL be declared in the tmux bind registry, in the tools group.

#### Scenario: Open a service from tmux

- **WHEN** pim presses `prefix + W`, types `graf` and presses Enter
- **THEN** Grafana opens in the browser
- **AND** the popup is closed

#### Scenario: Cancel

- **WHEN** pim presses `prefix + W` and then Escape
- **THEN** the popup closes and nothing opens

#### Scenario: Listed in the bindings menu

- **WHEN** pim opens `prefix + ?`
- **THEN** `W` is listed in the tools group as the lobby popup
