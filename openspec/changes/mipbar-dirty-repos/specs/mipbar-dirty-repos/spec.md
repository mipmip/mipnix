## ADDED Requirements

### Requirement: dirty repo count in the bar

mipbar SHALL show an icon with the number of dirty repositories reported by
`drs --json`, using the drs configuration of the user. The icon SHALL be
hidden when there are no dirty repositories. It SHALL be presented as a
uniform bar icon button.

#### Scenario: dirty repos present

- **WHEN** the last scan found 5 dirty repositories
- **THEN** the bar SHALL show the icon with the number 5

#### Scenario: nothing dirty

- **WHEN** the last scan found no dirty repositories
- **THEN** the icon SHALL be hidden

#### Scenario: scan fails

- **WHEN** `drs` is missing or exits with an error
- **THEN** the icon SHALL keep the result of the previous successful scan
- **AND** the tooltip SHALL say that the last scan failed

### Requirement: hourly scan and scan on open

mipbar SHALL scan once at start, then once an hour, and again each time the
popover opens. A scan that starts while another is running SHALL be skipped.

#### Scenario: hourly

- **WHEN** an hour has passed since the previous scheduled scan
- **THEN** mipbar SHALL run `drs --json` and update the icon

#### Scenario: popover opened

- **WHEN** the user opens the popover
- **THEN** mipbar SHALL scan again and update the list and the count with the
  result

#### Scenario: overlapping scans

- **WHEN** a scan is requested while one is still running
- **THEN** no second `drs` process SHALL be started

### Requirement: status overview tooltip

The icon's tooltip SHALL show the number of dirty repositories, the total
staged, unstaged and untracked counts across them, and the time of the last
scan.

#### Scenario: tooltip text

- **WHEN** the last scan at 14:34 found 3 repos with 52 staged, 4 unstaged and
  2 untracked files in total
- **THEN** the tooltip SHALL read
  `3 dirty repos` / `52 staged · 4 unstaged · 2 untracked` / `scanned 14:34`

### Requirement: popover lists the repos

Clicking the icon SHALL open a popover that lists each dirty repository by its
directory name with its path below it, home abbreviated as `~`, sorted by
path. The rows SHALL have no actions.

#### Scenario: list

- **WHEN** the user clicks the icon
- **THEN** a popover SHALL list every dirty repository from the latest scan

#### Scenario: no actions

- **WHEN** the user clicks a row
- **THEN** nothing SHALL happen
