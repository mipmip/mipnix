### Requirement: single-bar-on-preferred-monitor
The system SHALL display exactly one mipbar instance at any time, on the preferred monitor.

#### Scenario: laptop only
- **WHEN** only the laptop display (eDP) is connected
- **THEN** the bar SHALL be shown on the laptop display

#### Scenario: external monitor connected
- **WHEN** an external monitor (non-eDP) is connected alongside the laptop
- **THEN** the bar SHALL be shown on the external monitor only

#### Scenario: multiple external monitors
- **WHEN** multiple external monitors are connected
- **THEN** the bar SHALL be shown on the first external monitor

### Requirement: bar-follows-monitor-hotplug
The bar SHALL move to the preferred monitor when monitors are added or removed.

#### Scenario: external monitor plugged in
- **WHEN** an external monitor is connected while the bar is on the laptop display
- **THEN** the bar SHALL move from the laptop display to the external monitor

#### Scenario: external monitor unplugged
- **WHEN** the external monitor is disconnected while the bar is on it
- **THEN** the bar SHALL appear on the laptop display

### Requirement: no-duplicate-bars
There SHALL never be more than one bar window visible at the same time.

#### Scenario: monitor change cleanup
- **WHEN** the bar moves to a different monitor
- **THEN** the previous bar window SHALL be destroyed before the new one is created
