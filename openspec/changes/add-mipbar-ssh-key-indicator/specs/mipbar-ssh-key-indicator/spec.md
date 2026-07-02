# mipbar SSH Key Indicator

## ADDED Requirements

### Requirement: tri-state-ssh-key-indicator

mipbar SHALL display an always-visible indicator in the bar's `end` cluster that reports
the load state of the user's ed25519 key in the ssh-agent, distinguishing three states:
**loaded**, **unloaded** (agent reachable but key absent), and **no-agent** (agent
unreachable). Each state SHALL have a distinct icon and color cue.

#### Scenario: key is loaded in the agent

- **WHEN** the user's ed25519 key is present in the ssh-agent
- **THEN** the indicator SHALL show its "loaded" icon and color (solid/green lock)

#### Scenario: agent reachable but key not loaded

- **WHEN** the ssh-agent is reachable but the user's ed25519 key is not loaded
- **THEN** the indicator SHALL show its "unloaded" icon and color (open/amber lock)

#### Scenario: agent unreachable

- **WHEN** `ssh-add -l` reports the agent cannot be contacted (exit code 2)
- **THEN** the indicator SHALL show its "no-agent" icon and color (grey)

#### Scenario: indicator is always present

- **WHEN** the bar is rendered in any of the three states
- **THEN** the indicator SHALL remain visible (it SHALL NOT hide itself when the key is
  not loaded)

### Requirement: fingerprint-based-key-matching

The indicator SHALL determine whether "the user's key" is loaded by matching the SHA256
fingerprint of `~/.ssh/id_ed25519.pub`, computed at runtime, against the agent's listing —
not by matching the key comment.

#### Scenario: file comment differs from agent comment

- **WHEN** the public key file's comment differs from the comment the agent reports for the
  loaded key
- **THEN** the indicator SHALL still report "loaded", because the fingerprints match

#### Scenario: key rotated

- **WHEN** the user regenerates `~/.ssh/id_ed25519` (new fingerprint) without any code change
- **THEN** the indicator SHALL match against the new fingerprint, because the fingerprint is
  derived at runtime from the pubkey file

#### Scenario: a different key is loaded but the user's key is not

- **WHEN** the agent holds some other key whose fingerprint differs from
  `~/.ssh/id_ed25519.pub`
- **THEN** the indicator SHALL show the "unloaded" state

### Requirement: click-to-load-key

Clicking the indicator while in the **unloaded** state SHALL attempt to load the user's
ed25519 key into the agent via `ssh-add ~/.ssh/id_ed25519`, surfacing the agent's
passphrase prompt. Clicking in the **loaded** or **no-agent** states SHALL do nothing.

#### Scenario: click while unloaded

- **WHEN** the indicator is in the "unloaded" state
- **AND** the user clicks it
- **THEN** `ssh-add ~/.ssh/id_ed25519` SHALL be invoked, triggering the passphrase prompt

#### Scenario: indicator reflects the load after success

- **WHEN** the user successfully loads the key via the click action
- **THEN** the indicator SHALL transition to the "loaded" state on the next state refresh

#### Scenario: click while loaded or no-agent is a no-op

- **WHEN** the indicator is in the "loaded" or "no-agent" state
- **AND** the user clicks it
- **THEN** no load action SHALL be performed

### Requirement: periodic-state-refresh

The indicator SHALL refresh its state on a periodic poll consistent with mipbar's other
status indicators, so the displayed state reflects the current agent contents without
requiring user interaction.

#### Scenario: key loaded outside the bar

- **WHEN** the key is loaded into the agent by some other means (e.g. first SSH use unlocks
  it via gcr)
- **THEN** the indicator SHALL reflect the "loaded" state within one poll interval
