## MODIFIED Requirements

### Requirement: screenshare-icon
The screenshare indicator SHALL display a distinct icon that clearly communicates screen sharing is active. The icon SHALL be `screen-shared-symbolic` (or `display-symbolic` as fallback) — not the camera icon.

#### Scenario: indicator appearance
- **WHEN** screenshare is active
- **THEN** the indicator SHALL display `screen-shared-symbolic` or `display-symbolic`
