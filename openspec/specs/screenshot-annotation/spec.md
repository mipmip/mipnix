# screenshot-annotation Specification

## Purpose
TBD - created by archiving change add-screenshot-annotation. Update Purpose after archive.

## Requirements

### Requirement: annotate-from-the-notification

The notification announcing a saved screenshot SHALL offer annotation as a
visible, separately activatable choice, distinct from the action that reveals
the file.

Activating it SHALL open an annotation tool on that capture, focused and ready
to draw on.

#### Scenario: the choice is visible

- **WHEN** a screenshot notification is shown
- **THEN** it SHALL present an annotation control that is visibly distinct from
  the rest of the notification

#### Scenario: activating annotation

- **WHEN** the user activates the annotation control
- **THEN** an annotation tool SHALL open on the screenshot that notification
  announced

#### Scenario: revealing is unaffected

- **WHEN** the user activates the notification itself rather than the annotation
  control
- **THEN** the file SHALL be revealed in the file manager exactly as before this
  change, and no annotation tool SHALL open

#### Scenario: the annotation window takes focus

- **WHEN** the annotation tool is opened from the notification while another
  application has focus
- **THEN** the annotation window SHALL receive focus, rather than only being
  marked urgent

#### Scenario: notification expires unactivated

- **WHEN** the notification times out with neither control activated
- **THEN** no annotation tool SHALL open and no process SHALL remain waiting

#### Scenario: annotating the right capture

- **WHEN** two screenshot notifications are on screen and the annotation control
  of the older one is activated
- **THEN** the tool SHALL open the file that notification announced, not the most
  recent capture

### Requirement: capture-is-safe-before-annotation

The screenshot SHALL be fully saved, copied to the clipboard and recorded as the
most recent capture BEFORE annotation can begin, so that abandoning an annotation
costs nothing.

#### Scenario: abandoning an annotation

- **WHEN** the annotation tool is opened and then closed without saving
- **THEN** the original screenshot SHALL be unchanged on disk

#### Scenario: clipboard after abandoning

- **WHEN** an annotation is abandoned without saving
- **THEN** the clipboard SHALL still hold the unannotated capture

#### Scenario: reveal still works after abandoning

- **WHEN** an annotation is abandoned and the reveal keybind is pressed
- **THEN** the original capture SHALL be revealed

#### Scenario: annotation tool fails to start

- **WHEN** the annotation tool cannot be started
- **THEN** the screenshot SHALL remain saved, copied and revealable, and the
  failure SHALL NOT be silent

### Requirement: annotation-replaces-the-capture

Saving an annotation SHALL write the result to the same file as the original
capture, under the same name, and SHALL NOT create a second file.

#### Scenario: saving an annotation

- **WHEN** the user annotates a capture and saves
- **THEN** the annotated image SHALL be written to the original path

#### Scenario: no second file

- **WHEN** an annotation has been saved
- **THEN** the screenshot folder SHALL contain no additional file for that
  capture

#### Scenario: the most recent capture is still recorded correctly

- **WHEN** an annotation has been saved and the reveal keybind is pressed
- **THEN** the annotated file SHALL be revealed, with no separate step needed to
  keep that record in step

### Requirement: clipboard-follows-the-annotation

After an annotation is saved, the clipboard SHALL hold the annotated image, so
that a paste never silently yields the unannotated one.

#### Scenario: paste after annotating

- **WHEN** an annotation has been saved and the user pastes into an application
  that accepts images
- **THEN** the annotated image SHALL be pasted

#### Scenario: paste without annotating

- **WHEN** a capture is taken and no annotation is saved
- **THEN** a paste SHALL yield the unannotated capture

### Requirement: still-one-notification-per-capture

Annotating SHALL NOT cause a capture to produce more than one notification.

The annotation tool's own notifications SHALL be suppressed, and saving an
annotation SHALL NOT raise a further notification of its own.

#### Scenario: one notification through the whole flow

- **WHEN** a screenshot is captured, annotated and saved
- **THEN** exactly one notification SHALL have been shown for that capture

#### Scenario: no confirmation toast

- **WHEN** an annotation is saved
- **THEN** no additional notification SHALL be shown confirming it

### Requirement: capture-flow-unchanged

Taking a screenshot SHALL cost no more user actions than it did before this
change.

#### Scenario: the fast path

- **WHEN** the user takes a screenshot and does not want to annotate it
- **THEN** the capture SHALL complete with no additional interaction beyond what
  was required before this change, and no annotation tool SHALL open

#### Scenario: window capture

- **WHEN** the user takes a window screenshot
- **THEN** it SHALL behave exactly as before this change, annotation control
  included

### Requirement: declarative-provisioning

The annotation tool, its configuration and the scripts SHALL be provisioned
declaratively, with no step performed on any host and nothing that must be set up
through the tool's own interface.

#### Scenario: present after a rebuild

- **WHEN** a host with the Hyprland desktop role is rebuilt and the home profile
  switched
- **THEN** the annotation tool SHALL be installed, its configuration SHALL match
  the repository, and the scripts SHALL exist and be executable

#### Scenario: behaviour comes from the repository

- **WHEN** the annotation tool is launched from the notification
- **THEN** its save, discard, clipboard and notification behaviour SHALL be the
  behaviour declared in the repository

#### Scenario: no new keybind

- **WHEN** the change is built
- **THEN** no keybinding SHALL be added or altered
