## Purpose

A tmux popup that answers "is the mesh up" at a glance, showing nebula
reachability and HTTP endpoint status side by side without leaving the current
window or restarting the tools on every look.

## ADDED Requirements

### Requirement: prefix + M toggles the monitoring popup

The `pim-tmux` home-manager module SHALL bind `prefix + M` to a toggle. Pressed
outside the popup it SHALL open a centred popup showing the monitoring session.
Pressed inside the popup it SHALL close the popup.

The binding SHALL be declared in the flake-wide hotkey registry with the `tools`
group, so it is bound, listed in the `prefix + ?` menu and written to the
cheatsheets from one declaration.

#### Scenario: Opening the popup

- **WHEN** the user presses `prefix + M` in any session other than the
  monitoring session
- **THEN** a centred popup opens showing the monitoring session

#### Scenario: Closing from inside

- **WHEN** the user presses `prefix + M` while the popup is in front
- **THEN** the popup closes
- **AND** the underlying window is shown exactly as it was before the popup
  opened

#### Scenario: The binding is listed

- **WHEN** the user opens the `prefix + ?` menu
- **THEN** a row for `M` SHALL be present in the tools group with its
  description

### Requirement: Escape closes the popup

`Escape` SHALL close the popup while it is in front, without the prefix. It
SHALL leave the session and both tools running, exactly as the toggle does.

Outside the popup `Escape` SHALL reach the program in the pane unchanged, so
the key keeps its ordinary meaning everywhere else.

The key is taken from `nbping`, whose own `Escape` quits it. That is deliberate:
quitting a tool throws away the history this popup exists to accumulate and
leaves a dead pane in its place, so inside the popup `Escape` SHALL close the
popup rather than quit the tool.

`prefix + M` and tmux's own `prefix + d` SHALL continue to close the popup as
well.

#### Scenario: Closing with Escape

- **WHEN** the popup is in front and the user presses `Escape`
- **THEN** the popup SHALL close
- **AND** the monitoring session SHALL still exist with both tools running

#### Scenario: Escape outside the popup

- **WHEN** the popup is not in front and the user presses `Escape`
- **THEN** the key SHALL reach the program in the current pane
- **AND** no client SHALL be detached

#### Scenario: Escape does not quit nbping

- **WHEN** the `nbping` pane has focus inside the popup and the user presses
  `Escape`
- **THEN** `nbping` SHALL still be running after the popup closes
- **AND** its collected history SHALL be intact on the next open

#### Scenario: The other two ways still work

- **WHEN** the user presses `prefix + M` or `prefix + d` with the popup in front
- **THEN** the popup SHALL close
- **AND** both tools SHALL keep running

### Requirement: Two tools in one popup, side by side

The popup SHALL show one window split into two panes along a vertical divider:
`nping` on the left and `updo` on the right. Each pane SHALL get an equal share
of the width.

The popup SHALL be wide enough that each pane can render its table, which
`nping -v table` and `updo` both need. A popup width of less than the full
terminal gives each tool less than half a screen, so the popup SHALL be sized at
or near the terminal width rather than at the narrower default used by the
picker popups.

#### Scenario: Both tools visible at once

- **WHEN** the popup is open
- **THEN** `nping` output SHALL be visible in the left pane
- **AND** `updo` output SHALL be visible in the right pane
- **AND** neither pane SHALL be hidden behind the other

#### Scenario: Equal split

- **WHEN** the popup opens
- **THEN** the two panes SHALL be of equal width

#### Scenario: Moving between the panes

- **WHEN** the user presses the pane navigation keys inside the popup
- **THEN** focus SHALL move between the `nping` and `updo` panes

### Requirement: The monitoring session outlives the popup

Closing the popup SHALL detach the popup's client and SHALL NOT kill the session
behind it. Both tools SHALL keep running, so the next open shows accumulated
history rather than two tools starting from nothing.

The session SHALL be created on the first open and SHALL NOT be created a second
time while it exists.

#### Scenario: History survives a close

- **WHEN** the user opens the popup, waits for several `nping` intervals, closes
  the popup and opens it again
- **THEN** the `nping` pane SHALL show the samples collected while the popup was
  closed
- **AND** `updo` SHALL show its uptime percentages computed over that whole
  period, not restarted from the second open

#### Scenario: No duplicate session

- **WHEN** the popup is opened for the second time
- **THEN** exactly one monitoring session SHALL exist
- **AND** exactly two panes SHALL be in it

#### Scenario: The session is not in the way

- **WHEN** the user opens the session and window tree with `prefix + s`
- **THEN** the monitoring session SHALL be distinguishable from the user's own
  sessions by its name

### Requirement: A tool that has exited is restarted on the next open

If `nping` or `updo` has exited, crashed or been quit, the next open SHALL
restore a working pane running that tool rather than showing a dead pane or an
idle shell.

#### Scenario: One tool quit

- **WHEN** the user quits `updo` inside the popup, closes the popup, and opens
  it again
- **THEN** the right pane SHALL be running `updo` again
- **AND** the left pane's `nping` SHALL still be the process that was running
  before, with its history intact

#### Scenario: Both tools gone

- **WHEN** the monitoring session exists but neither tool is running
- **THEN** opening the popup SHALL leave both panes running their tools

### Requirement: The nebula host list comes from the registry

The hosts `nping` watches SHALL be derived at build time from the
`flake.nebulaNodes` registry, the same single source the `prefix + H` ssh picker
reads. No list of host names SHALL be written anywhere else.

#### Scenario: Every active node is watched

- **WHEN** the popup is opened
- **THEN** `nping` SHALL list every node present in `flake.nebulaNodes`,
  servers and laptops alike

#### Scenario: Adding a node needs no second edit

- **WHEN** a new host is added to `flake.nebulaNodes`
- **THEN** it SHALL appear in the monitor after a rebuild
- **AND** no file outside that host's own definition SHALL have been edited

#### Scenario: A node absent from the registry

- **WHEN** a host is not in `flake.nebulaNodes`
- **THEN** it SHALL NOT be watched

#### Scenario: A laptop that is off

- **WHEN** a laptop node in the registry is powered down
- **THEN** it SHALL be listed and reported unreachable
- **AND** the other hosts' rows SHALL be unaffected

### Requirement: The popup opens without fetching anything

`nping` and `updo` SHALL be part of the built closure and SHALL be referenced by
store path. The popup SHALL NOT resolve a flake reference or reach the network
to start either tool.

#### Scenario: Opening with no network

- **WHEN** the machine has no working internet connection and the user opens the
  popup
- **THEN** both tools SHALL start
- **AND** `nping` SHALL report on the nebula overlay as it normally does

#### Scenario: No fetch delay

- **WHEN** the popup is opened on a machine that has never run these tools
- **THEN** it SHALL open without a download step

### Requirement: The smug monitoring session agrees with the popup

The `monitoring` smug session's `nping` and `updo` panes SHALL use the same
packaged binaries and the same derived host list as the popup, so the two views
cannot report on different sets of hosts.

#### Scenario: Same hosts in both views

- **WHEN** a host is added to `flake.nebulaNodes`
- **THEN** it SHALL appear both in the popup and in the smug monitoring session

#### Scenario: No hardcoded list left

- **WHEN** the smug session definition is inspected
- **THEN** it SHALL NOT contain a literal list of nebula host names
- **AND** it SHALL NOT invoke the tools through a flake reference resolved at
  run time
