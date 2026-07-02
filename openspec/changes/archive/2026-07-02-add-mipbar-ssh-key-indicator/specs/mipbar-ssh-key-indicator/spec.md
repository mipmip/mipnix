# mipbar SSH Key Indicator

## ADDED Requirements

### Requirement: four-state-ssh-key-indicator

mipbar SHALL display an always-visible indicator in the bar's `end` cluster that reports
the load state of the user's ed25519 key in the ssh-agent, distinguishing four states:
**loaded** (key present AND the agent can sign with it), **unloaded** (agent reachable but
key absent), **stale** (key listed in the agent but the agent cannot sign with it), and
**no-agent** (agent unreachable). Each state SHALL have a distinct icon and color cue.

#### Scenario: key is loaded and signable

- **WHEN** the user's ed25519 key is present in the ssh-agent AND the agent can sign with
  it (`ssh-add -T` succeeds within a short timeout)
- **THEN** the indicator SHALL show its "loaded" icon (open/unlocked padlock) and color
  (green)

#### Scenario: agent reachable but key not loaded

- **WHEN** the ssh-agent is reachable but the user's ed25519 key is not loaded
- **THEN** the indicator SHALL show its "unloaded" icon (closed/locked padlock) and color
  (amber)

#### Scenario: key listed but not signable

- **WHEN** the user's ed25519 key appears in `ssh-add -l` but the agent cannot sign with it
  (`ssh-add -T` fails or times out)
- **THEN** the indicator SHALL show its "stale" icon (lock-with-alert) and color (red)

#### Scenario: agent unreachable

- **WHEN** `ssh-add -l` reports the agent cannot be contacted (exit code 2)
- **THEN** the indicator SHALL show its "no-agent" icon and color (grey)

#### Scenario: signability, not mere listing, defines "loaded"

- **WHEN** the sign check (`ssh-add -T`) is used to distinguish "loaded" from "stale"
- **THEN** the check SHALL be bounded by a timeout so a hung agent cannot stall the poll,
  and a timed-out or failed sign SHALL be treated as "stale", never "loaded"

#### Scenario: indicator is always present

- **WHEN** the bar is rendered in any of the four states
- **THEN** the indicator SHALL remain visible (it SHALL NOT hide itself when the key is
  not loaded)

### Requirement: fingerprint-based-key-matching

The indicator SHALL determine whether "the user's key" is present by matching the SHA256
fingerprint of `~/.ssh/id_ed25519.pub`, computed at runtime, against the agent's listing —
not by matching the key comment.

#### Scenario: file comment differs from agent comment

- **WHEN** the public key file's comment differs from the comment the agent reports for the
  loaded key
- **THEN** the indicator SHALL still recognize the key as present, because the fingerprints
  match

#### Scenario: key rotated

- **WHEN** the user regenerates `~/.ssh/id_ed25519` (new fingerprint) without any code change
- **THEN** the indicator SHALL match against the new fingerprint, because the fingerprint is
  derived at runtime from the pubkey file

#### Scenario: a different key is loaded but the user's key is not

- **WHEN** the agent holds some other key whose fingerprint differs from
  `~/.ssh/id_ed25519.pub`
- **THEN** the indicator SHALL show the "unloaded" state

### Requirement: click-through-popover-actions

Clicking the indicator SHALL open a popover that reports the current state in words and,
when an action is applicable, offers a button to change it. The popover SHALL NOT silently
do nothing on click.

#### Scenario: popover in the unloaded or stale state offers Load

- **WHEN** the indicator is in the "unloaded" or "stale" state
- **AND** the user opens the popover and activates the action button ("Load")
- **THEN** `ssh-add ~/.ssh/id_ed25519` SHALL be invoked, surfacing a passphrase prompt via
  a standalone askpass GUI

#### Scenario: popover in the loaded state offers Unload

- **WHEN** the indicator is in the "loaded" state
- **AND** the user opens the popover and activates the action button ("Unload")
- **THEN** `ssh-add -d ~/.ssh/id_ed25519` SHALL be invoked to remove the key from the agent

#### Scenario: loaded popover shows the fingerprint

- **WHEN** the indicator is in the "loaded" state
- **THEN** the popover SHALL display the key's SHA256 fingerprint

#### Scenario: no-agent popover offers no action

- **WHEN** the indicator is in the "no-agent" state
- **THEN** the popover SHALL state the agent is unreachable and SHALL NOT offer a
  Load/Unload button

#### Scenario: an action fires its prompt exactly once

- **WHEN** the user activates the Load button
- **THEN** exactly one `ssh-add` invocation (and thus at most one passphrase popup) SHALL
  occur per activation, even on repeated or rapid clicks while one is in flight

#### Scenario: indicator reflects the result immediately

- **WHEN** a Load or Unload action completes (successfully or not)
- **THEN** the indicator SHALL re-poll immediately and update to the resulting state
  without waiting for the next periodic poll interval

### Requirement: passphrase-prompt-scoped-to-widget

The GUI passphrase prompt SHALL be triggered only by the widget's own Load action, not by
ordinary terminal `ssh`/`ssh-add` usage. The askpass environment (`SSH_ASKPASS`,
`SSH_ASKPASS_REQUIRE`) SHALL be set inline on the widget's `ssh-add` invocation and SHALL
NOT be exported as session-wide environment variables.

#### Scenario: terminal ssh prompts on the tty

- **WHEN** the user runs `ssh <host>` or `ssh-add` in a terminal that needs the passphrase
- **THEN** the passphrase prompt SHALL appear on the terminal (tty), NOT as the GUI askpass
  popup

#### Scenario: widget Load uses the GUI askpass

- **WHEN** the widget's Load action runs `ssh-add` from the detached bar (no controlling tty)
- **THEN** it SHALL use a standalone askpass GUI (its path baked into the bar at build time),
  so the passphrase popup appears solely as a result of the widget click

#### Scenario: passphrase popup is floated

- **WHEN** the standalone askpass window appears under the Hyprland compositor
- **THEN** it SHALL float (and center) rather than tile into the layout

### Requirement: plain-ssh-agent-not-gcr

The session SHALL use a plain OpenSSH `ssh-agent` for `SSH_AUTH_SOCK` rather than gcr's
ssh-agent, so that the agent can reliably sign with a passphrase-protected key and the
indicator's Load/Unload actions work. gcr's ssh-agent SHALL be masked; gnome-keyring SHALL
be retained for its non-SSH secrets role.

#### Scenario: SSH_AUTH_SOCK points at the plain agent

- **WHEN** a graphical session starts
- **THEN** `SSH_AUTH_SOCK` SHALL point at the plain OpenSSH `ssh-agent` socket
  (`$XDG_RUNTIME_DIR/ssh-agent`), set for the whole session (not only login shells), so the
  bar and GUI apps use it

#### Scenario: gcr ssh-agent is inert

- **WHEN** the session is running
- **THEN** gcr's ssh-agent socket and service SHALL be masked so they cannot claim
  `SSH_AUTH_SOCK` or hold an unsignable listing of the key

#### Scenario: secrets service still available

- **WHEN** apps that use the Secret Service (e.g. libsecret consumers) run
- **THEN** gnome-keyring SHALL still provide `org.freedesktop.secrets`; only its SSH role is
  removed

### Requirement: periodic-state-refresh

The indicator SHALL refresh its state on a periodic poll consistent with mipbar's other
status indicators, so the displayed state reflects the current agent contents without
requiring user interaction.

#### Scenario: key loaded outside the bar

- **WHEN** the key is loaded into the agent by some other means (e.g. `ssh-add` in a terminal)
- **THEN** the indicator SHALL reflect the "loaded" state within one poll interval
