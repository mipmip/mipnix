# Workspace Navigation

## MODIFIED Requirements

### Requirement: show-occupied-workspaces

The bar SHALL display a button for each hyprland workspace that has at least one client (window). Empty workspaces SHALL NOT be shown. The workspace list SHALL react to client-level changes (open, close, move) in addition to workspace-level changes (added, removed).

#### Scenario: workspace with windows is visible

- **WHEN** a workspace has one or more clients
- **THEN** the bar SHALL display a button for that workspace

#### Scenario: empty workspace is hidden

- **WHEN** a workspace has zero clients
- **THEN** the bar SHALL NOT display a button for that workspace

#### Scenario: workspace becomes empty

- **WHEN** the last client is removed from a workspace
- **THEN** the button for that workspace SHALL be removed from the bar

#### Scenario: window opens in empty workspace

- **WHEN** a client is added to a previously empty workspace
- **THEN** a button for that workspace SHALL appear in the bar

#### Scenario: client added to existing workspace triggers update

- **WHEN** a client is added to a workspace that already has clients
- **THEN** the workspace button SHALL re-render to reflect the updated client list

#### Scenario: client moved between workspaces triggers update

- **WHEN** a client moves from one workspace to another
- **THEN** both the source and destination workspace buttons SHALL re-render to reflect their updated client lists
