## MODIFIED Requirements

### Requirement: authenticatable-lock

The screen locker SHALL have a PAM service of its own, so that a locked session
can be unlocked with the account password. The locker SHALL NOT rely on the
`other` fallback stack, which denies every authentication attempt.

On a host with an enrolled fingerprint, the locker SHALL also accept that
fingerprint. Either the password or the fingerprint SHALL unlock the session
on its own; the locker SHALL NOT require both.

#### Scenario: PAM service present after build

- **WHEN** a host with the Hyprland desktop role is built
- **THEN** `/etc/pam.d/hyprlock` SHALL exist

#### Scenario: password unlocks the session

- **WHEN** the session is locked and the user types the account password
- **THEN** the session SHALL unlock
- **AND** no fingerprint SHALL be asked for

#### Scenario: wrong password does not unlock

- **WHEN** the session is locked and an incorrect password is entered
- **THEN** the session SHALL remain locked

#### Scenario: fingerprint unlocks the session

- **WHEN** the session is locked on a host with an enrolled fingerprint and
  the user puts that finger on the reader without typing anything
- **THEN** the session SHALL unlock

#### Scenario: unknown finger does not unlock

- **WHEN** the session is locked and a finger that is not enrolled is put on
  the reader
- **THEN** the session SHALL remain locked
- **AND** the password SHALL still unlock it

#### Scenario: host without a fingerprint reader

- **WHEN** the session is locked on a host without fprintd or without a reader
- **THEN** the password SHALL unlock the session as before
