## ADDED Requirements

### Requirement: System monitor icon in bar
The bar SHALL display a static monitor icon (󰍛) in the end section.

#### Scenario: Icon visible
- **WHEN** the bar is running
- **THEN** a monitor icon is visible in the bar's end section

### Requirement: Popover with sensor readings
Clicking the monitor icon SHALL open a popover displaying CPU usage, memory usage, network throughput, disk usage, local IP, and external IP.

#### Scenario: Popover opens
- **WHEN** the user clicks the monitor icon
- **THEN** a popover opens showing all sensor readings

#### Scenario: Popover content
- **WHEN** the popover is open
- **THEN** it displays CPU percentage, memory used/total, network download/upload speed, disk used/total, local IP address, and external IP address

### Requirement: Sensors poll at appropriate intervals
Each sensor SHALL poll at an interval suited to its rate of change: CPU, memory, and network at 3-5 seconds; disk at 60 seconds; local IP at 30 seconds; external IP at 300 seconds.

#### Scenario: Fast sensors update frequently
- **WHEN** the popover is open for 10 seconds
- **THEN** CPU, memory, and network values have updated at least once

#### Scenario: External IP updates infrequently
- **WHEN** the bar has been running for 5 minutes
- **THEN** the external IP has been fetched no more than twice

### Requirement: Graceful failure for external IP
The external IP sensor SHALL display a fallback value if the network request fails.

#### Scenario: No internet
- **WHEN** the external IP fetch fails
- **THEN** the value displays "N/A" instead of an error
