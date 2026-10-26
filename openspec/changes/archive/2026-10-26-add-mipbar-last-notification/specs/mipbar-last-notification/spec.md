## Purpose

Gives the bar a way back to notifications that just disappeared: one button that
opens a scrollable list of the most recent notifications, including screenshots
that can be reopened from their own card.

## ADDED Requirements

### Requirement: notification-list-in-the-bar

The bar SHALL offer a notification button that opens a popover containing a
scrollable list of recent notifications, newest first. Each card SHALL show the
application name, the summary, the body, the arrival time and, when the
notification carries one, its image.

The list SHALL retain at most 50 notifications, dropping the oldest first. The
button SHALL be visible even when the list is empty, and the popover SHALL then
say that there are no recent notifications rather than opening empty.

#### Scenario: open the notification list

- **WHEN** several notifications have been delivered and the user activates the
  notification button
- **THEN** the popover SHALL show a scrollable list with the most recent one
  first, each card showing its application name, summary and body

#### Scenario: nothing captured yet

- **WHEN** the list is empty and the user activates the notification button
- **THEN** the popover SHALL state that there are no recent notifications

#### Scenario: a newer notification arrives

- **WHEN** the popover is open and another notification is delivered
- **THEN** the new notification SHALL appear at the top of the list

#### Scenario: notification has no body

- **WHEN** a notification consists only of a summary
- **THEN** its card SHALL show the summary without an empty body area

#### Scenario: more than the limit

- **WHEN** more than 50 notifications have been delivered
- **THEN** the list SHALL contain the 50 most recent and the oldest SHALL be gone

#### Scenario: many notifications

- **WHEN** the list holds more notifications than fit in the popover
- **THEN** the popover SHALL keep a bounded height and the list SHALL scroll
  through the remaining cards

### Requirement: keeps-recent-notifications

The recent notifications SHALL remain available after their toasts have closed,
expired or been dismissed from the notification daemon.

#### Scenario: toast expired

- **WHEN** a notification was shown, its toast expired, and the user opens the
  notification button
- **THEN** that notification SHALL still be in the list

#### Scenario: toast dismissed

- **WHEN** the user dismisses a toast in the notification daemon and then opens
  the notification button in the bar
- **THEN** the notification SHALL still be in the list

#### Scenario: replaced notification

- **WHEN** an application updates a notification it already sent
- **THEN** the list SHALL show the updated content as the most recent entry, with
  only one card for that notification

#### Scenario: older notifications stay

- **WHEN** a newer notification arrives
- **THEN** the notifications already in the list SHALL remain below it

### Requirement: survives-a-bar-restart

The list SHALL be read from a cache at startup, so that restarting the bar or
logging in again does not lose it.

#### Scenario: restart the bar

- **WHEN** the bar is restarted after notifications were captured
- **THEN** the notification button SHALL still show the same list in the same
  order

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

- **WHEN** a notification from a chat client or a build tool is shown in the list
- **THEN** its card SHALL show its text and image, and no action buttons

#### Scenario: activate a generic card

- **WHEN** the user clicks the card of a generic notification
- **THEN** nothing SHALL be launched and the popover SHALL stay usable

### Requirement: reopen-a-screenshot

When a notification announces a saved screenshot, activating its image or its
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

- **WHEN** the card shows a screenshot, newer notifications have arrived since,
  and the user clicks the screenshot image
- **THEN** the file revealed SHALL be the screenshot on that card

#### Scenario: file has been deleted

- **WHEN** the screenshot on a card no longer exists and the user clicks it
- **THEN** the user SHALL be told that the file is gone, and no file manager
  window SHALL open

#### Scenario: notification without an image

- **WHEN** a screenshot notification carries no image path
- **THEN** its card SHALL still offer reveal and annotation for the recorded
  capture

### Requirement: clear-the-list

The popover SHALL offer a control that clears the whole notification list, and
SHALL close when the user clicks outside it.

#### Scenario: clear

- **WHEN** the user activates the clear control
- **THEN** every card SHALL disappear and the popover SHALL show its empty state

#### Scenario: cleared list stays cleared

- **WHEN** the user clears the list and restarts the bar
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
- **THEN** the bar SHALL start normally and the popover SHALL show its empty state
