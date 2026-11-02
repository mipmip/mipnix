## ADDED Requirements

### Requirement: fingerprint-only-at-the-lock-screen

On Hyprland hosts the fingerprint SHALL be accepted at the screen lock only.
The screen locker SHALL check it itself, next to the password, and SHALL NOT
go through `pam_fprintd`. The `hyprlock`, `sudo` and `polkit-1` PAM services
SHALL NOT contain `pam_fprintd`. GDM SHALL keep its own fingerprint handling.

#### Scenario: PAM stacks without pam_fprintd

- **WHEN** a host with the Hyprland desktop role and fprintd enabled is built
- **THEN** `/etc/pam.d/hyprlock`, `/etc/pam.d/sudo` and `/etc/pam.d/polkit-1`
  SHALL NOT reference `pam_fprintd.so`

#### Scenario: sudo asks for the password at once

- **WHEN** the user runs `sudo` on a host with an enrolled fingerprint
- **THEN** sudo SHALL prompt for the password straight away
- **AND** SHALL NOT wait for a finger

#### Scenario: polkit asks for the password

- **WHEN** an action needs polkit authentication
- **THEN** the polkit agent SHALL ask for the password only

#### Scenario: GDM unchanged

- **WHEN** a host with GDM and an enrolled fingerprint is built
- **THEN** the GDM fingerprint PAM service SHALL still exist
