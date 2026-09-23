# Screenshot Capture

## ADDED Requirements

### Requirement: dedicated-screenshot-folder

Screenshots taken in the Hyprland session SHALL be saved to a folder used for
nothing else, so that the pictures folder stays free of them and the containing
folder is meaningful on its own.

The folder SHALL be configured once, in the session environment, so that a
screenshot taken from a keybind and one taken by running the capture tool from a
terminal land in the same place.

#### Scenario: capture from a keybind

- **WHEN** the user takes a screenshot with the region or window keybind
- **THEN** the file SHALL be written under the dedicated screenshot folder and
  SHALL NOT be written to the pictures folder root

#### Scenario: capture from a terminal

- **WHEN** the user runs the capture tool directly from a shell in the session
- **THEN** the file SHALL be written to the same dedicated folder

#### Scenario: folder does not exist yet

- **WHEN** a screenshot is taken and the dedicated folder is absent
- **THEN** it SHALL be created and the capture SHALL succeed

### Requirement: clipboard-unchanged

Capturing a screenshot SHALL continue to place the image on the Wayland
clipboard, and SHALL continue to save it to disk, exactly as before this change.

#### Scenario: paste after capture

- **WHEN** a screenshot has been taken and the user pastes into an application
  that accepts images
- **THEN** the captured image SHALL be pasted

#### Scenario: both outputs on one capture

- **WHEN** a screenshot is taken
- **THEN** the image SHALL be both on the clipboard and present as a file

### Requirement: actionable-notification

A saved screenshot SHALL be announced by exactly one notification, and that
notification SHALL carry an activatable action. The notification SHALL show the
captured image as its icon.

Exactly one notification means the capture tool's own notification is
suppressed when the change's notification is sent, so the user never sees two
for one capture.

#### Scenario: one notification per capture

- **WHEN** a screenshot is saved
- **THEN** exactly one notification SHALL appear

#### Scenario: notification carries an action

- **WHEN** the notification is shown
- **THEN** it SHALL carry an action the user can activate, rather than being a
  dismiss-only card

#### Scenario: thumbnail

- **WHEN** the notification is shown
- **THEN** the captured image SHALL be used as the notification icon

#### Scenario: notification service unavailable

- **WHEN** the notification daemon is not running at the time of capture
- **THEN** the screenshot SHALL still be saved and copied to the clipboard, and
  the failure SHALL NOT surface as an error to the user

### Requirement: reveal-on-activation

Activating the screenshot notification SHALL open the containing folder in the
file manager with the captured file selected, and SHALL bring that window to the
front with focus.

The reveal SHALL address the file manager through the
`org.freedesktop.FileManager1` interface rather than by invoking a named file
manager binary, so that it reuses an already open window, works when the file
manager is not running, and does not hard-code which file manager is installed.

#### Scenario: activate the notification

- **WHEN** the user activates the screenshot notification
- **THEN** the file manager SHALL open the folder containing the screenshot with
  that file selected

#### Scenario: file manager already open

- **WHEN** the file manager already has a window open and the notification is
  activated
- **THEN** the existing window SHALL be used, and a second window SHALL NOT be
  spawned

#### Scenario: file manager not running

- **WHEN** no file manager is running and the notification is activated
- **THEN** one SHALL be started and SHALL show the folder with the file selected

#### Scenario: revealed window is focused

- **WHEN** the notification is activated from a workspace showing another
  application
- **THEN** the file manager window SHALL receive focus, rather than only being
  marked urgent

#### Scenario: notification expires unactivated

- **WHEN** the notification times out without being activated
- **THEN** no file manager window SHALL open and no process SHALL remain waiting

### Requirement: reveal-last-by-keybind

The most recently captured screenshot SHALL remain revealable by keybind after
its notification has expired.

The path of each capture SHALL be recorded before the notification is sent, so
that the keybind works even when the notification could not be shown.

#### Scenario: reveal after the notification is gone

- **WHEN** a screenshot was taken, its notification has expired, and the user
  presses the reveal keybind
- **THEN** the file manager SHALL open that screenshot's folder with the file
  selected

#### Scenario: several captures in a row

- **WHEN** several screenshots have been taken and the user presses the reveal
  keybind
- **THEN** the most recent capture SHALL be revealed

#### Scenario: recorded file has been deleted

- **WHEN** the recorded screenshot no longer exists and the reveal keybind is
  pressed
- **THEN** the user SHALL be told so through a notification, and no file manager
  window SHALL open

#### Scenario: no screenshot taken yet

- **WHEN** the reveal keybind is pressed before any screenshot has been taken in
  this session or a previous one
- **THEN** the user SHALL be told so, and nothing SHALL fail visibly

### Requirement: capture-does-not-block

The capture SHALL complete and its process SHALL exit without waiting for the
user to act on the notification.

#### Scenario: capture completes while the notification waits

- **WHEN** a screenshot is taken and the notification is left untouched
- **THEN** the capture process SHALL have exited, and only the notification
  handler SHALL remain, for no longer than the notification lifetime

#### Scenario: capture immediately after a capture

- **WHEN** a second screenshot is taken while the first notification is still on
  screen
- **THEN** the second capture SHALL succeed, and the recorded most-recent path
  SHALL become the second file

#### Scenario: activating an older notification

- **WHEN** two notifications are on screen and the user activates the older one
- **THEN** the file revealed SHALL be the one that notification announced, not
  the most recent capture

### Requirement: declarative-provisioning

The scripts, keybinds and screenshot folder setting SHALL be provisioned
declaratively by home-manager, and SHALL require no new package beyond what the
Hyprland session already installs.

#### Scenario: present after switch

- **WHEN** the home profile is switched on a host with the Hyprland desktop role
- **THEN** the scripts SHALL exist under the session config directory and SHALL
  be executable, and the keybinds SHALL be present in the Hyprland config

#### Scenario: no new dependencies

- **WHEN** the change is built
- **THEN** no package SHALL be added to the system or home package sets
