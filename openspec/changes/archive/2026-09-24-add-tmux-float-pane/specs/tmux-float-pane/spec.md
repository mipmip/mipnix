## Purpose

A toggle that shows the current tmux pane centred in a popup with margins and
puts it back exactly where it was, for the times when a pane needs to be in
front for a minute without the window being given over to it entirely.

## ADDED Requirements

### Requirement: A key floats the current pane and brings it back

One key SHALL move the current pane into a popup, and the same key SHALL bring
it back. No other action SHALL be needed to return to the normal layout.

While floated, the pane SHALL remain usable: input reaches it and its output is
visible, exactly as in place.

#### Scenario: Floating a pane

- **WHEN** the toggle is pressed in a window with several panes
- **THEN** the current pane SHALL appear in a centred popup
- **AND** the pane SHALL still accept input and show output

#### Scenario: Bringing it back

- **WHEN** the toggle is pressed while a pane is floating
- **THEN** the popup SHALL close
- **AND** the pane SHALL be back in the window

#### Scenario: The running process is undisturbed

- **WHEN** a pane running a long-lived process is floated and brought back
- **THEN** that process SHALL still be running
- **AND** its scrollback SHALL be intact

### Requirement: The layout is restored exactly

Bringing a pane back SHALL restore the window to the layout it had before, not
an equivalent one. The pane SHALL return to its own slot at its own size, and
every other pane SHALL be untouched.

#### Scenario: A pane in the middle of a layout

- **WHEN** a pane that is neither the first nor the last in a window of three or
  more is floated and brought back
- **THEN** the window layout SHALL be identical to what it was before floating
- **AND** the restored pane SHALL be the current pane again

#### Scenario: Other panes are not resized

- **WHEN** a pane is floated
- **THEN** the remaining panes SHALL keep their sizes
- **AND** the slot the floated pane came from SHALL still be occupied

### Requirement: The background does not show the layout it is standing in for

While a pane is floating, the window behind the popup SHALL show a blank pane
rather than the rest of the layout, so the popup reads as the thing in front
rather than as an overlay on a working window.

#### Scenario: Background while floating

- **WHEN** a pane is floating
- **THEN** the window behind the popup SHALL show a single blank pane

#### Scenario: Background after returning

- **WHEN** the pane is brought back
- **THEN** the window SHALL show the full layout again, not a blank pane

### Requirement: The popup width is adjustable while floating

Two keys SHALL widen and narrow the popup in fixed steps while a pane is
floating. The width SHALL be bounded, so neither key can reduce the popup to
nothing or push it past full width.

The same keys SHALL keep their ordinary behaviour outside the float, because
they are useful keys that a feature used for a minute at a time has no claim on.

#### Scenario: Widening and narrowing

- **WHEN** the widen key is pressed inside the float
- **THEN** the popup SHALL become one step wider
- **AND** the narrow key SHALL make it one step narrower

#### Scenario: Width is clamped

- **WHEN** the widen key is pressed repeatedly at maximum width
- **THEN** the popup SHALL stay at maximum width
- **AND** the same SHALL hold for the narrow key at minimum width

#### Scenario: The width is remembered

- **WHEN** a pane is floated after the width was changed in an earlier float
- **THEN** the popup SHALL open at the remembered width

#### Scenario: The keys outside the float

- **WHEN** the narrow key is pressed while no pane is floating
- **THEN** it SHALL perform its ordinary binding
- **AND** nothing about the float SHALL change

#### Scenario: Resizing with nothing floating

- **WHEN** a width key somehow reaches the resize path with no float in progress
- **THEN** nothing SHALL happen and no error SHALL be shown

### Requirement: A float left in an unusual state still comes back

The toggle SHALL restore the pane from any state the float can be left in, not
only from the state the popup was opened in. Closing the popup without using the
toggle SHALL leave the pane recoverable rather than stranded.

#### Scenario: The popup was detached from inside

- **WHEN** the user detaches from inside the popup instead of pressing the
  toggle, and later presses the toggle
- **THEN** the pane SHALL be restored to its slot

#### Scenario: The window was zoomed before floating

- **WHEN** a pane is floated from a window that was already zoomed and is then
  brought back
- **THEN** the window SHALL be zoomed again, as it was

### Requirement: The pane is never destroyed by the toggle

Bringing a pane back SHALL NOT be able to destroy it. The hidden session is
removed only once it holds the placeholder and not the floated pane, so a
restore that does not complete leaves the pane alive to be recovered rather than
killed along with the session.

#### Scenario: The restore did not complete

- **WHEN** the floated pane is not back in its slot at the point the hidden
  session would be removed
- **THEN** the session SHALL NOT be removed
- **AND** the pane SHALL still exist

#### Scenario: Normal removal

- **WHEN** the pane has been swapped back and the hidden session holds only the
  placeholder
- **THEN** the session SHALL be removed
- **AND** no session belonging to the float SHALL remain

### Requirement: The float leaves nothing behind

Once a pane is back, no trace of the float SHALL remain: no hidden session, no
placeholder pane, and no leftover state that would confuse the next toggle.

#### Scenario: After returning

- **WHEN** the pane has been brought back
- **THEN** listing sessions SHALL NOT show the float's session

#### Scenario: Toggling again

- **WHEN** the toggle is used again after a completed round trip
- **THEN** it SHALL float the current pane as if for the first time
