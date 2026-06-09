# Tmux Beans Popup


### Requirement: beans-tui-popup-keybind

A tmux keybinding `prefix + B` SHALL open the `beans tui` interactive task manager in a large `display-popup`.

#### Scenario: opening the popup

- **WHEN** the user presses `prefix + B` in tmux
- **THEN** a `display-popup` sized 90% × 90% SHALL open running `beans tui`

#### Scenario: popup closes on exit

- **WHEN** the user quits the `beans tui` running in the popup
- **THEN** the popup SHALL close automatically (the bind uses `popup -E`)

#### Scenario: runs in the active pane's directory

- **WHEN** the popup is opened from a pane with a given working directory
- **THEN** `beans tui` SHALL run in that pane's current directory (so it operates on the current project's beans)

### Requirement: no-binding-displaced

Adding the `prefix + B` binding SHALL NOT remove or override any existing tmux keybinding.

#### Scenario: lowercase b unchanged

- **WHEN** the new binding is added
- **THEN** the existing `prefix + b` (status-bar toggle) and all other bindings SHALL remain unchanged (uppercase `B` was previously unbound)
