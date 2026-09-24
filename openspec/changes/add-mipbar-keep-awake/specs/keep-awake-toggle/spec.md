## Purpose

A bar control that suspends the session's idle lock and display blank on
request, so the machine can be left alone while it is still doing something the
keyboard and pointer cannot see.

## ADDED Requirements

### Requirement: A bar control toggles keep-awake

The bar SHALL show a control that turns the keep-awake state on and off with a
single click. The control SHALL show which state it is in without being opened
or hovered.

#### Scenario: Turning it on

- **WHEN** the user clicks the control while keep-awake is off
- **THEN** the idle inhibit SHALL be taken
- **AND** the control SHALL show the on state

#### Scenario: Turning it off

- **WHEN** the user clicks the control while keep-awake is on
- **THEN** the idle inhibit SHALL be released
- **AND** the control SHALL show the off state

#### Scenario: The state is legible at a glance

- **WHEN** the bar is visible
- **THEN** the control SHALL distinguish on from off by both its glyph and its
  colour, rather than by colour alone

#### Scenario: Rapid clicking

- **WHEN** the control is clicked again while the previous click is still being
  carried out
- **THEN** the second click SHALL be ignored
- **AND** the resulting state SHALL be the one the first click asked for

### Requirement: Keep-awake suspends the idle lock and the display blank

While keep-awake is on, the session SHALL NOT lock itself on inactivity and the
display SHALL NOT be powered down on inactivity. Both thresholds SHALL resume
their normal behaviour when it is turned off.

#### Scenario: Idle past the lock threshold while on

- **WHEN** keep-awake is on and the session has received no input for longer
  than the idle lock threshold
- **THEN** the session SHALL NOT be locked

#### Scenario: Idle past the display threshold while on

- **WHEN** keep-awake is on and the session has received no input for longer
  than the display blank threshold
- **THEN** the display SHALL stay powered

#### Scenario: Normal behaviour returns

- **WHEN** keep-awake is turned off
- **THEN** the idle lock and the display blank SHALL apply again from that point

### Requirement: Keep-awake does not inhibit sleep

The inhibit SHALL cover idle only. An explicit request to sleep SHALL still be
honoured while keep-awake is on, because a lock that also covered sleep would
turn "stay awake" into "refuse to suspend", and the suspend binding would fail
with no visible reason.

#### Scenario: Explicit suspend while on

- **WHEN** keep-awake is on and the user presses the suspend binding
- **THEN** the machine SHALL suspend

#### Scenario: Lid close while on

- **WHEN** keep-awake is on and the lid is closed
- **THEN** the machine SHALL suspend as it normally does

#### Scenario: Manual lock while on

- **WHEN** keep-awake is on and the user locks the session deliberately
- **THEN** the session SHALL lock

### Requirement: The inhibit is visible to the rest of the system

The inhibit SHALL be held as a named lock that the standard tooling can list,
so that an unexplained absence of locking can be traced without reading the
bar's source.

#### Scenario: Listing inhibitors

- **WHEN** keep-awake is on and the session's inhibitors are listed
- **THEN** an entry SHALL be present naming the bar as the holder, naming `idle`
  as what is inhibited, and carrying a human-readable reason

#### Scenario: Nothing left behind

- **WHEN** keep-awake is off
- **THEN** no inhibitor belonging to the bar SHALL be listed

### Requirement: The state survives a bar reload

The control SHALL derive its state from the system rather than from a variable
of its own, so that restarting the bar neither loses the inhibit nor
misrepresents it.

#### Scenario: Bar restarted while on

- **WHEN** keep-awake is on and the bar is restarted
- **THEN** the inhibit SHALL still be held
- **AND** the control SHALL show the on state

#### Scenario: Released from outside the bar

- **WHEN** the inhibit is released by some other means than the control
- **THEN** the control SHALL show the off state without needing a click

#### Scenario: A previous attempt left a failed unit

- **WHEN** a previous keep-awake attempt left its unit in a failed state
- **THEN** turning keep-awake on SHALL still take the inhibit rather than fail
  silently

### Requirement: Keep-awake is off at session start

The session SHALL start with keep-awake off, so that the strict idle policy is
what applies unless someone asks otherwise in this session.

#### Scenario: Fresh login

- **WHEN** a session starts
- **THEN** keep-awake SHALL be off
- **AND** the idle lock and display blank SHALL apply
