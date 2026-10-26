## Purpose

Gives the bar a way back to the notification that just disappeared: one button
that shows the most recent notification, including screenshots that can be
reopened from it.

## ADDED Requirements

### Requirement: latest-notification-in-the-bar

The bar SHALL offer a notification button that opens a popover showing the most
recent notification. The card SHALL show the application name, the summary, the
body, the arrival time and, when the notification carries one, its image.

The button SHALL be visible even when no notification has been captured, and the
popover SHALL then say that there is nothing to show rather than opening empty.

#### Scenario: open the latest notification

- **WHEN** at least one notification has been delivered and the user activates
  the notification button
- **THEN** a popover SHALL show the most recent one, with its application name,
  summary and body

#### Scenario: nothing captured yet

- **WHEN** no notification has been delivered since the last cache clear and the
  user activates the notification button
- **THEN** the popover SHALL state that there is no recent notification

#### Scenario: a newer notification arrives

- **WHEN** the popover is open and another notification is delivered
- **THEN** the card SHALL show the newer notification

#### Scenario: notification has no body

- **WHEN** the most recent notification consists only of a summary
- **THEN** the card SHALL show the summary without an empty body area

### Requirement: survives-the-toast

The most recent notification SHALL remain available after its toast has closed,
expired or been dismissed from the notification daemon.

#### Scenario: toast expired

- **WHEN** a notification was shown, its toast expired, and the user opens the
  notification button
- **THEN** that notification SHALL still be shown

#### Scenario: toast dismissed

- **WHEN** the user dismisses the toast in the notification daemon and then opens
  the notification button in the bar
- **THEN** the notification SHALL still be shown

#### Scenario: replaced notification

- **WHEN** an application updates a notification it already sent
- **THEN** the card SHALL show the updated content, and only one card SHALL exist

### Requirement: survives-a-bar-restart

The most recent notification SHALL be read from a cache at startup, so that
restarting the bar or logging in again does not lose it.

#### Scenario: restart the bar

- **WHEN** the bar is restarted after a notification was captured
- **THEN** the notification button SHALL still show that notification

#### Scenario: cache is absent or unreadable

- **WHEN** the bar starts and the cache is missing, empty or not valid
- **THEN** the bar SHALL start normally and the popover SHALL show its empty state

#### Scenario: no duplicate capture

- **WHEN** the bar restarts
- **THEN** exactly one capture of new notifications SHALL run, not one per past
  start

### Requirement: read-only-for-other-applications

A notification from an application other than the screenshot tool SHALL be
presented without controls that claim to invoke its actions. Activating its card
SHALL NOT run anything.

Actions in a notification are identifiers understood by the application that
sent it. The bar cannot execute them on that application's behalf.

#### Scenario: generic notification

- **WHEN** a notification from a chat client or a build tool is shown in the
  popover
- **THEN** it SHALL show its text and image, and no action buttons

#### Scenario: activate a generic card

- **WHEN** the user clicks the card of a generic notification
- **THEN** nothing SHALL be launched and the popover SHALL stay usable

### Requirement: reopen-a-screenshot

When the notification announces a saved screenshot, activating its image or its
card SHALL open the file manager with that file selected, through the
`org.freedesktop.FileManager1` interface, exactly as activating the screenshot
notification itself does.

A separate control SHALL open the annotation tool on that same file. Both
actions SHALL use the path from the notification being shown, not the most
recent capture on disk, so an older card keeps pointing at its own file.

#### Scenario: click the image

- **WHEN** the user clicks the image of a screenshot card
- **THEN** the file manager SHALL show the folder containing that screenshot with
  the file selected

#### Scenario: click the card

- **WHEN** the user clicks the screenshot card outside its controls
- **THEN** the same reveal SHALL happen

#### Scenario: annotate from the bar

- **WHEN** the user activates the annotation control on a screenshot card
- **THEN** the annotation tool SHALL open on that screenshot

#### Scenario: a newer notification exists

- **WHEN** the card shows a screenshot, a newer notification has arrived since,
  and the user clicks the screenshot image
- **THEN** the file revealed SHALL be the screenshot on the card

#### Scenario: file has been deleted

- **WHEN** the screenshot on the card no longer exists and the user clicks it
- **THEN** the user SHALL be told that the file is gone, and no file manager
  window SHALL open

#### Scenario: notification without an image

- **WHEN** a screenshot notification carries no image path
- **THEN** the card SHALL still offer reveal and annotation for the recorded
  capture

### Requirement: clear-the-card

The popover SHALL offer a control that clears the last notification, and SHALL
close when the user clicks outside it.

#### Scenario: clear

- **WHEN** the user activates the clear control
- **THEN** the card SHALL disappear and the popover SHALL show its empty state

#### Scenario: cleared notification stays cleared

- **WHEN** the user clears the card and restarts the bar
- **THEN** the empty state SHALL remain

#### Scenario: click outside

- **WHEN** the popover is open and the user clicks elsewhere on the desktop or
  the bar
- **THEN** the popover SHALL close

### Requirement: no-change-to-the-notification-flow

Capturing and showing notifications SHALL NOT alter what the notification daemon
or the screenshot tool does. No notification SHALL be suppressed, delayed,
replaced or duplicated by the bar.

#### Scenario: screenshot flow unchanged

- **WHEN** a screenshot is taken
- **THEN** it SHALL still produce its one actionable notification, and the bar
  SHALL merely record it

#### Scenario: daemon configuration untouched

- **WHEN** the change is built and the session starts
- **THEN** the notification daemon SHALL run with the same configuration as
  before, and no configuration file for it SHALL be added

#### Scenario: daemon not running

- **WHEN** no notification daemon is running and the bar starts
- **THEN** the bar SHALL start normally and the popover SHALL show its empty
  state
