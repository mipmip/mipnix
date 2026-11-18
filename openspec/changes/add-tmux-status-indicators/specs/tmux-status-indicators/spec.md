# Spec Delta

## Purpose

Keeps the load state of the user's ssh key and the number of dirty repos visible in
the tmux status bar on every host, and lets the user load the key on a remote host
without a graphical session.

## ADDED Requirements

### Requirement: status-bar-shows-ssh-key-state

The tmux status bar SHALL show an always-visible ssh key segment, using the same
four states and icons as mipbar: loaded (open padlock, green), unloaded (closed
padlock, amber), stale (lock with alert, red) and no agent (cross, grey).

#### Scenario: key is loaded and signable

- **WHEN** the key matching `~/.ssh/id_ed25519.pub` is in the agent AND the agent
  can sign with it within the timeout
- **THEN** the segment SHALL show the open padlock in green

#### Scenario: agent reachable but key not loaded

- **WHEN** the agent is reachable and the key matching the public key file is absent
- **THEN** the segment SHALL show the closed padlock in amber

#### Scenario: key listed but not signable

- **WHEN** the key is listed by `ssh-add -l` but the sign check fails or times out
- **THEN** the segment SHALL show the lock with alert in red

#### Scenario: agent unreachable

- **WHEN** `ssh-add -l` exits with the code for an unreachable agent
- **THEN** the segment SHALL show the cross in grey

#### Scenario: public key file is missing

- **WHEN** `~/.ssh/id_ed25519.pub` does not exist and the agent is reachable
- **THEN** the segment SHALL show the unloaded state and SHALL NOT match an
  unrelated agent key by an empty fingerprint

#### Scenario: segment is always present

- **WHEN** the status bar is drawn in any of the four states
- **THEN** the segment SHALL be present, including when the key is not loaded

### Requirement: status-key-state-matches-mipbar

The tmux segment SHALL decide "my key" by the SHA256 fingerprint of the public key
file, computed at runtime, and SHALL treat a key as loaded only when the agent can
actually sign with it. The sign check SHALL be bounded by a timeout.

#### Scenario: comment differs between file and agent

- **WHEN** the comment in the public key file differs from the comment the agent
  reports
- **THEN** the segment SHALL still recognize the key as loaded because the
  fingerprints match

#### Scenario: a different key is loaded

- **WHEN** the agent holds a key whose fingerprint differs from the public key file
- **THEN** the segment SHALL show the unloaded state

#### Scenario: hung agent cannot stall the status bar

- **WHEN** the agent accepts the listing request but the sign check does not return
- **THEN** the check SHALL time out and the segment SHALL show the stale state

### Requirement: status-refreshes-without-manual-redraw

The status bar SHALL re-evaluate the ssh key and dirty repo segments at least every
15 seconds, and a key load SHALL trigger an immediate redraw.

#### Scenario: key loaded outside tmux

- **WHEN** the key is loaded by an `ssh` or `ssh-add` outside the status bar
- **THEN** the segment SHALL show the new state within one refresh interval

#### Scenario: key loaded through the binding

- **WHEN** the unlock popup successfully loads the key
- **THEN** the status bar SHALL be redrawn immediately, without waiting for the
  interval

### Requirement: key-unlock-binding

tmux SHALL bind `prefix + U` to open a popup that loads `~/.ssh/id_ed25519` with a
passphrase prompt on the popup's terminal.

#### Scenario: key is not loaded

- **WHEN** the user presses `prefix + U` while the key is not loaded
- **THEN** a popup SHALL run `ssh-add` with a tty prompt, and successful entry SHALL
  load the key into the local agent

#### Scenario: key is already loaded

- **WHEN** the user presses `prefix + U` while the key is loaded and signable
- **THEN** the popup SHALL report that the key is loaded and SHALL NOT ask for a
  passphrase

#### Scenario: no agent is running

- **WHEN** the user presses `prefix + U` and the agent is unreachable
- **THEN** the popup SHALL report that no agent is available, wait for a keypress,
  and SHALL NOT remove or overwrite the key file

#### Scenario: key file is missing

- **WHEN** the user presses `prefix + U` and `~/.ssh/id_ed25519` does not exist
- **THEN** the popup SHALL say so, wait for a keypress, and exit without erroring
  out of the popup

### Requirement: status-bar-shows-dirty-repo-count

The tmux status bar SHALL show a dirty repo segment with the dirty repo icon and
the number of repos reported by `drs`, and SHALL hide the segment when the count
is zero.

#### Scenario: there are dirty repos

- **WHEN** `drs` reports one or more dirty repos
- **THEN** the segment SHALL show the dirty repo icon followed by the count

#### Scenario: no dirty repos

- **WHEN** `drs` reports no dirty repos
- **THEN** the segment SHALL be hidden

#### Scenario: scan fails

- **WHEN** `drs` fails or returns unparseable output
- **THEN** the segment SHALL keep the last known count and SHALL NOT break the
  rest of the status bar

### Requirement: dirty-repo-scan-is-cached

The dirty repo count SHALL be cached so that status refreshes within the cache
window do not run `drs` again.

#### Scenario: several refreshes within one minute

- **WHEN** the status bar refreshes repeatedly within the cache window
- **THEN** `drs` SHALL run at most once for that window

#### Scenario: cache is older than the window

- **WHEN** the cached count is older than the cache window
- **THEN** the next refresh SHALL run `drs` and update the cache

### Requirement: status-helpers-exist-on-cli-hosts

The tmux module SHALL provide the status and unlock helpers as installed commands,
so hosts with only the CLI profile have them without mipbar.

#### Scenario: CLI-only host

- **WHEN** tmux starts on a host that does not install mipbar
- **THEN** both status segments and the `prefix + U` binding SHALL work
