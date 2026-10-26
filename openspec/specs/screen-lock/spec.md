# screen-lock Specification

## Purpose
TBD - created by archiving change restore-screen-auto-lock. Update Purpose after archive.

## Requirements

### Requirement: authenticatable-lock

The screen locker SHALL have a PAM service of its own, so that a locked session
can be unlocked with the account password. The locker SHALL NOT rely on the
`other` fallback stack, which denies every authentication attempt.

#### Scenario: PAM service present after build

- **WHEN** a host with the Hyprland desktop role is built
- **THEN** `/etc/pam.d/hyprlock` SHALL exist

#### Scenario: password unlocks the session

- **WHEN** the session is locked and the user types the account password
- **THEN** the session SHALL unlock

#### Scenario: wrong password does not unlock

- **WHEN** the session is locked and an incorrect password is entered
- **THEN** the session SHALL remain locked

### Requirement: idle-lock-timer

The session SHALL lock itself automatically after a bounded period of user
inactivity, without any user action, so an unattended workstation does not stay
readable.

The timer SHALL be suspendable on purpose. While a deliberate idle inhibit is
held, as the bar's keep-awake control does, the timer SHALL NOT fire, and it
SHALL apply again once the inhibit is released. This is the one exception: an
inhibit has to be asked for, it is visible in the session's inhibitor list while
it is held, and it does not survive the session.

#### Scenario: idle past the lock threshold

- **WHEN** the session has received no keyboard or pointer input for 10 minutes
- **THEN** the screen SHALL be locked and SHALL require authentication to return

#### Scenario: activity before the threshold

- **WHEN** the user provides input before the threshold elapses
- **THEN** the idle period SHALL restart and the screen SHALL NOT lock

#### Scenario: lock survives further idling

- **WHEN** the session has been locked by the idle timer and remains idle
- **THEN** it SHALL stay locked, and no timeout SHALL unlock it

#### Scenario: only one locker instance

- **WHEN** a lock is requested while the session is already locked
- **THEN** a second locker instance SHALL NOT be started

#### Scenario: idle past the threshold while an inhibit is held

- **WHEN** a deliberate idle inhibit is held and the session passes the
  threshold with no input
- **THEN** the screen SHALL NOT be locked

#### Scenario: the inhibit is released

- **WHEN** a held idle inhibit is released
- **THEN** the idle lock timer SHALL apply again from that point

#### Scenario: no inhibit outlives the session

- **WHEN** a new session starts
- **THEN** no idle inhibit SHALL be in force
- **AND** the timer SHALL apply

### Requirement: lock-before-sleep

The session SHALL be locked before the machine enters any sleep state,
regardless of what triggered the sleep, so that resuming presents a lock screen
rather than the previous desktop.

#### Scenario: lid closed

- **WHEN** the laptop lid is closed and the machine suspends
- **THEN** the session SHALL be locked before the suspend completes, and
  reopening the lid SHALL present the lock screen

#### Scenario: suspend requested by hand

- **WHEN** the user runs `systemctl suspend` or uses the suspend keybind
- **THEN** the session SHALL be locked before the suspend completes

#### Scenario: display restored on resume

- **WHEN** the machine resumes from sleep
- **THEN** the display SHALL be powered on and SHALL show the lock screen

### Requirement: no-idle-suspend

The machine SHALL NOT suspend, hibernate, or otherwise sleep as a result of
inactivity. Sleep SHALL happen only on an explicit request from the user, such
as closing the lid, the suspend keybind, or a suspend command.

#### Scenario: long idle period

- **WHEN** the session has been idle well past every lock and display threshold
- **THEN** the machine SHALL still be awake and reachable over the network

#### Scenario: idle policy declared

- **WHEN** a host with the Hyprland desktop role is built
- **THEN** the logind idle action SHALL be declared as `ignore` in the
  configuration rather than left to an upstream default

#### Scenario: display power saving is not sleep

- **WHEN** the display has been powered down after 15 minutes of inactivity
- **THEN** the machine SHALL remain awake, and input SHALL restore the display
  to the lock screen

### Requirement: manual-lock-binding

The user SHALL be able to lock the session on demand, by a keybinding that does
not depend on the idle daemon being alive.

#### Scenario: lock keybind

- **WHEN** the user presses the lock keybinding
- **THEN** the session SHALL lock immediately

#### Scenario: lock and suspend keybind

- **WHEN** the user presses the lock-and-suspend keybinding
- **THEN** the session SHALL be locked and the machine SHALL then suspend, in
  that order

#### Scenario: idle daemon not running

- **WHEN** the idle daemon is not running and the user presses the lock
  keybinding
- **THEN** the session SHALL still lock

### Requirement: legible-lock-screen

The lock screen SHALL render its text legibly, so the user can see the password
field, the clock, and the date.

#### Scenario: lock screen text renders

- **WHEN** the lock screen is displayed
- **THEN** the clock, the date, and the password placeholder SHALL render as
  readable text and SHALL NOT render as missing-glyph boxes
