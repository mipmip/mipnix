# Spec Delta

## Purpose

Gives every pim host, including CLI-only servers, a plain OpenSSH ssh-agent at a
known socket so an unlocked key can be reused by git, `gh` and ssh without asking
for the passphrase again.

## ADDED Requirements

### Requirement: agent-available-on-every-host

Every host that imports the pim CLI profile SHALL run a plain OpenSSH ssh-agent as
a user service and SHALL export `SSH_AUTH_SOCK` for the whole session.

#### Scenario: CLI-only server has an agent

- **WHEN** the user logs in on a host without the desktop profile
- **THEN** `SSH_AUTH_SOCK` SHALL point at the plain agent and `ssh-add -l` SHALL
  report an empty agent (exit code 1) instead of an unreachable agent (exit code 2)

#### Scenario: the agent is the plain OpenSSH one

- **WHEN** the agent is inspected
- **THEN** it SHALL be the OpenSSH `ssh-agent`, not gcr's forwarding shim

### Requirement: agent-start-removes-stale-socket

The agent service SHALL remove a leftover socket file before it starts, so a
killed agent does not prevent the next start.

#### Scenario: previous agent was killed

- **WHEN** the agent process died without removing its socket and the user service
  starts again
- **THEN** the stale socket SHALL be removed and the agent SHALL bind successfully

### Requirement: keys-are-added-on-first-use

The ssh client configuration SHALL set `AddKeysToAgent yes` on every host, so the
first ssh that uses the key hands it to the agent.

#### Scenario: first ssh after boot

- **WHEN** the user runs an ssh command that needs `~/.ssh/id_ed25519` and the key
  is not in the agent
- **THEN** the passphrase prompt SHALL appear on the terminal and the key SHALL be
  added to the agent

#### Scenario: later commands reuse the agent

- **WHEN** the key has been added and a later git, `gh` or ssh command needs it
- **THEN** the command SHALL use the agent without prompting for the passphrase

### Requirement: no-session-wide-askpass

The shared agent configuration SHALL NOT export `SSH_ASKPASS` or
`SSH_ASKPASS_REQUIRE` for the session, so a passphrase prompt in a terminal or a
tmux popup stays on that terminal.

#### Scenario: popup prompts on its own terminal

- **WHEN** the key is loaded from the tmux popup on a host without a graphical
  session
- **THEN** the passphrase prompt SHALL appear in the popup and SHALL NOT look for a
  GUI askpass program
