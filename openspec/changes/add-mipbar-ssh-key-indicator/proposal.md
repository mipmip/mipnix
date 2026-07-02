## Why

There is no quick, glanceable way to know whether the ssh-agent currently holds the
user's personal ed25519 key. The agent in use is gnome-keyring's gcr agent
(`SSH_AUTH_SOCK=/run/user/1000/gcr/ssh`), which lazily unlocks keys on first use, so
"is my key already unlocked this session?" is a real, recurring question. Today the only
way to check is to drop to a terminal and run `ssh-add -l`. mipbar already hosts a row of
small status indicators (camera, screenshare, system monitor) in its `end` cluster, so a
key-status indicator fits the existing pattern and surface.

The exploration also surfaced a concrete matching subtlety: the public-key file's comment
(`post@pimsnel.com`) does **not** match the comment the agent reports for the loaded key
(`pim@ojs`). Matching by comment is therefore unreliable; the **fingerprint**
(`SHA256:99MlTK/GhZ3bAsQBDeB4+oAvqy5cpHxRPy+MN6JRRVM`) is identical in both and is the
only stable, host-independent identifier.

## What Changes

- **New mipbar status indicator (`SshKey`).** A small, always-visible tri-state widget in
  the bar's `end` cluster (alongside Camera/Screenshare/SystemMonitor) showing whether the
  user's ed25519 key is loaded in the ssh-agent:
  - **loaded** — the key's fingerprint is present in `ssh-add -l` → solid/green lock 🔑.
  - **unloaded** — agent reachable but the fingerprint is absent → open/amber lock 🔓.
  - **no-agent** — agent unreachable (`ssh-add -l` exit code 2) → grey ✖.
- **Fingerprint-based matching.** The "my key" predicate is computed at runtime from
  `~/.ssh/id_ed25519.pub` via `ssh-keygen -lf`, so it survives key rotation and the
  comment mismatch found during exploration. It is not hardcoded.
- **Click-to-load.** Clicking the indicator while in the **unloaded** state runs
  `ssh-add ~/.ssh/id_ed25519`, triggering the gcr/askpass passphrase prompt so the key can
  be unlocked from the bar. Clicking in the loaded or no-agent states is a no-op.
- **Polling.** State is refreshed on a poll (≈5s), consistent with the other status
  indicators. `ssh-add -l` is local and cheap.

## Capabilities

### New Capabilities

- `mipbar-ssh-key-indicator`: A tri-state mipbar indicator that reports whether the user's
  ed25519 key (matched by fingerprint) is loaded in the ssh-agent, with a click action to
  load it when it is not.

## Impact

- `packages/mipbar/widget/SshKey.tsx`: new widget, modeled on `Camera.tsx`
  (`createPoll` + `<box>`/`<button>` + `tooltipText`).
- `packages/mipbar/widget/Bar.tsx`: import `SshKey` and add `<SshKey />` to the `end`
  `<box>` (next to Camera/Screenshare/SystemMonitor).
- `packages/mipbar/style.scss`: add `.SshKey` styling with `.loaded` / `.unloaded` /
  `.noagent` state classes (color cues).
- `modules/USERS/pim/programs/mipbar/default.nix`: `ssh-keygen`/`ssh-add` were confirmed
  already on the bar's PATH (systemwide), so no `pkgs.openssh` was needed. Instead added a
  standalone askpass (`pkgs.lxqt.lxqt-openssh-askpass`) plus `SSH_ASKPASS` /
  `SSH_ASKPASS_REQUIRE` session variables, so click-to-load can prompt for the passphrase.
- No change to ssh-agent / gnome-keyring configuration; the indicator only reads agent
  state and (on click) calls `ssh-add`.

## Open Questions

- **askpass routing under gcr.** *(Resolved during implementation.)* `ssh-add`, invoked
  from the detached mipbar process, does **not** route through gcr's askpass — gcr's helper
  refuses standalone invocation, and no askpass is on PATH by default. Resolution: the
  mipbar module pins a standalone askpass (`pkgs.lxqt.lxqt-openssh-askpass`) and sets
  `SSH_ASKPASS` + `SSH_ASKPASS_REQUIRE=force` via `home.sessionVariables`. See `design.md`.
