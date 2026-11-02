## MODIFIED Requirements

### Requirement: Connect into a per-host window in the nebula-prive session

On selecting a host, the picker SHALL ensure a dedicated tmux session named
`nebula-prive` exists, open (or reuse) a window named after the selected host
that runs an ssh command for that host's registry IP, and switch the client to
it. The ssh command SHALL allocate a TTY and SHALL start the remote login shell
with `NEBULA_TMUX=1` in its environment. Selecting the same host again SHALL
reuse its existing window rather than opening a duplicate.

#### Scenario: First connection to a host

- **WHEN** the user selects `durer` and no `nebula-prive` session exists
- **THEN** a detached `nebula-prive` session SHALL be created, a window named
  `durer` SHALL be opened running
  `ssh -t pim@192.168.100.12 'env NEBULA_TMUX=1 "$SHELL" -l'`, and the client
  SHALL be switched to `nebula-prive:durer`

#### Scenario: Reconnecting to an already-open host

- **WHEN** the user selects `durer` and a `durer` window already exists in the
  `nebula-prive` session
- **THEN** the client SHALL switch to the existing `nebula-prive:durer` window
  and no second `durer` window SHALL be created

#### Scenario: Second host joins the same session

- **WHEN** the user selects `hurry` while the `nebula-prive` session already
  holds a `durer` window
- **THEN** a new `hurry` window SHALL be added to the same `nebula-prive`
  session and the client SHALL be switched to it

## ADDED Requirements

### Requirement: Second prefix in the popup's tmux

A tmux server started from a shell whose environment carries
`NEBULA_TMUX=1` SHALL accept `C-s` as an additional prefix, leaving `C-a` as
the primary prefix. A server started without that marker SHALL keep its
existing prefix configuration. The prefixes SHALL be decided when the server
starts, so a server that is already running when the popup connects keeps its
current prefixes until it is restarted.

#### Scenario: Starting tmux from the popup

- **WHEN** the user runs `t` in a shell opened by the picker and no remote tmux
  server is running
- **THEN** the new server SHALL have `C-a` as prefix and `C-s` as `prefix2`

#### Scenario: Starting tmux outside the popup

- **WHEN** the user starts tmux from a direct ssh shell or at the host's
  console
- **THEN** the server SHALL NOT gain `C-s` as `prefix2`

#### Scenario: Attaching to a server that was already running

- **WHEN** the picker connects to a host whose tmux server was started without
  the marker
- **THEN** the server SHALL keep its existing prefixes until it is restarted

### Requirement: Second prefix visible in the status bar

A tmux server started with `NEBULA_TMUX=1` SHALL show the additional prefix key
in its status bar next to the primary prefix key. A server started without that
marker SHALL continue to show only the primary prefix key. The marker server
SHALL use 👻 as its leading status-bar marker; a server without it SHALL keep 🤠.

#### Scenario: Popup server shows both prefixes

- **WHEN** the remote server was started from the popup and accepts `C-s` as
  `prefix2`
- **THEN** its status bar SHALL show both `C-a` and `C-s`, with 👻 as its marker

#### Scenario: Direct server shows only the primary prefix

- **WHEN** the server was started from a direct ssh shell or the console
- **THEN** its status bar SHALL show `C-a` without `C-s`, with 🤠 as its marker
