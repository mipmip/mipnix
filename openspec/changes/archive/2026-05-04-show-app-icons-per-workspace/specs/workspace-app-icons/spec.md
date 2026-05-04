# Workspace App Icons

## ADDED Requirements

### Requirement: display-app-icons

Each workspace button SHALL display one desktop-themed icon per window (client) running in that workspace, alongside the workspace ID.

#### Scenario: workspace with one app

- **WHEN** a workspace contains a single client with class "firefox"
- **THEN** the workspace button SHALL show the workspace ID and the "firefox" icon from the GTK icon theme

#### Scenario: workspace with multiple different apps

- **WHEN** a workspace contains clients with classes "firefox", "kitty", and "discord"
- **THEN** the workspace button SHALL show the workspace ID followed by one icon per client

#### Scenario: multiple windows of same app

- **WHEN** a workspace contains three clients all with class "firefox"
- **THEN** the workspace button SHALL show three "firefox" icons (one per window, not deduplicated)

### Requirement: fallback-icon

When a client's class does not resolve to a valid icon in the GTK icon theme, the system SHALL display the `application-x-executable` icon as a fallback.

#### Scenario: unknown app class

- **WHEN** a workspace contains a client with class "some_unknown_app"
- **AND** the GTK icon theme has no entry for "some_unknown_app"
- **THEN** the workspace button SHALL display the `application-x-executable` fallback icon for that client

### Requirement: per-icon-tooltip

Hovering over an individual app icon within a workspace button SHALL display a tooltip showing that specific window's title.

#### Scenario: hover shows individual window title

- **WHEN** the user hovers over a "firefox" icon in a workspace button
- **THEN** a tooltip SHALL appear showing that specific window's title (e.g. "Mozilla Firefox — GitHub")

#### Scenario: two windows of same app have different tooltips

- **WHEN** a workspace contains two "firefox" clients with titles "GitHub" and "Wikipedia"
- **AND** the user hovers over each icon
- **THEN** each icon SHALL show its own window title, not a combined list

#### Scenario: tooltip updates when window title changes

- **WHEN** a client's title changes (e.g. user navigates to a new page)
- **THEN** the tooltip for that icon SHALL reflect the updated title

### Requirement: reactive-icon-updates

Workspace button icons SHALL update immediately when clients are added, removed, or moved between workspaces.

#### Scenario: window opens in existing workspace

- **WHEN** a new client opens in a workspace that already has other clients
- **THEN** the workspace button SHALL immediately show an icon for the new application

#### Scenario: window closes

- **WHEN** a client is closed in a workspace
- **THEN** the icon for that window SHALL be removed from the workspace button

#### Scenario: window moves to another workspace

- **WHEN** a client moves from workspace 1 to workspace 2
- **THEN** workspace 1's button SHALL remove the icon for that window
- **AND** workspace 2's button SHALL add the icon for that window
