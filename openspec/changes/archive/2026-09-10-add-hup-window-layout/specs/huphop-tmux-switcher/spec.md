## MODIFIED Requirements

### Requirement: Selecting a repo creates or switches to its org session and repo window

Selecting a repository in the multiplex TUI SHALL clone it first if it is not yet
present, then run the `switch_command` wrapper. The wrapper SHALL place each
repository in a tmux session named for its provider+owner and a window named for
the repository (the session-per-org, window-per-repo model), creating whichever of
the session or window does not yet exist and then switching the current client to
that session and window. Session and window names SHALL be sanitised so that `.`
and `:` cannot break tmux target syntax. The wrapper SHALL only issue tmux server
commands and require no controlling TTY, since it is executed without a shell while
the TUI still owns the terminal.

Every window the wrapper CREATES SHALL be arranged into three panes: one pane
occupying the left 50% of the window's width, and the remaining right 50% split
into a top and a bottom pane of equal height.

```
┌──────────────────┬──────────────────┐
│                  │       top        │
│       left       ├──────────────────┤
│                  │      bottom      │
└──────────────────┴──────────────────┘
         50%                50%
```

All three panes SHALL be plain interactive shells with no command run in them,
and all three SHALL start in the repo's local checkout path. The left pane SHALL
be the window's active pane when the client is switched to it.

The wrapper SHALL NOT alter the pane arrangement of a window it did not create in
this invocation, so re-selecting an already-open repository leaves that window's
panes exactly as the user left them.

#### Scenario: First repo of an org

- **WHEN** the selected repo's org session does not exist
- **THEN** the wrapper creates a detached session named `<short>-><owner>` with a
  window named `<repo>` rooted at the repo's local checkout path
- **AND** that window is arranged into the three-pane layout with the left pane active
- **AND** switches the current client to that session and window

#### Scenario: Additional repo of an existing org

- **WHEN** the org session exists but has no window for the selected repo
- **THEN** the wrapper creates a new window named `<repo>` in that session rooted
  at the checkout path
- **AND** that window is arranged into the three-pane layout with the left pane active
- **AND** switches the current client to that window

#### Scenario: Repo already open

- **WHEN** the org session and the repo window both already exist
- **THEN** the wrapper creates nothing
- **AND** the existing window's panes are left untouched, however many there are
- **AND** switches the current client to the existing session and window

#### Scenario: Repo not yet cloned

- **WHEN** the selected repo has no local checkout
- **THEN** huphop clones it before the wrapper runs
- **AND** the resulting checkout path is used as the window's working directory
- **AND** as the starting directory of all three panes

#### Scenario: Panes start as shells in the checkout

- **WHEN** a window has just been created by the wrapper
- **THEN** each of its three panes is an interactive shell with no command issued
  into it
- **AND** each pane's starting directory is the repo's local checkout path

#### Scenario: Layout survives a window resize

- **WHEN** a window created by the wrapper is resized
- **THEN** the panes keep their proportions — left at about half the width, and the
  right column split about evenly in height

#### Scenario: User rearranges a window and returns to it

- **WHEN** the user closes or resizes panes in a window the wrapper created, and
  later selects that same repository again
- **THEN** the wrapper does not re-split, re-balance, or re-focus that window
- **AND** only switches the current client to it
