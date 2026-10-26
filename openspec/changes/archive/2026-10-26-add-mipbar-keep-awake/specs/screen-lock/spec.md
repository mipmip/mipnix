## MODIFIED Requirements

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
