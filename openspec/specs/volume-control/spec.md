# Volume Control

## ADDED Requirements

### Requirement: speaker-volume

The panel SHALL display a slider for the default audio speaker volume.

#### Scenario: adjust speaker volume

WHEN the user drags the speaker slider
THEN the default audio sink volume SHALL change accordingly

#### Scenario: speaker volume reflects system state

WHEN the panel opens
THEN the speaker slider SHALL reflect the current system speaker volume

### Requirement: mic-volume

The panel SHALL display a slider for the default microphone volume.

#### Scenario: adjust mic volume

WHEN the user drags the mic slider
THEN the default audio source volume SHALL change accordingly

#### Scenario: mic volume reflects system state

WHEN the panel opens
THEN the mic slider SHALL reflect the current system microphone volume
