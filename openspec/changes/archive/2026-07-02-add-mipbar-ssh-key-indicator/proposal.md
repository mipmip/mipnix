## Why

There is no quick, glanceable way to know whether the ssh-agent currently holds the
user's personal ed25519 key. Today the only way to check is to drop to a terminal and run
`ssh-add -l`. mipbar already hosts a row of small status indicators (camera, screenshare,
system monitor) in its `end` cluster, so a key-status indicator fits the existing pattern
and surface.

The exploration surfaced a concrete matching subtlety: the public-key file's comment
(`post@pimsnel.com`) does **not** always match the comment the agent reports for the loaded
key (e.g. `pim@ojs`). Matching by comment is therefore unreliable; the **fingerprint**
(`SHA256:99MlTK/GhZ3bAsQBDeB4+oAvqy5cpHxRPy+MN6JRRVM`) is identical in both and is the only
stable, host-independent identifier.

Implementation also uncovered a deeper problem: the original agent was gnome-keyring's gcr
ssh-agent, which would keep the passphrase-protected key in its `ssh-add -l` listing while
being **unable to sign with it** — so the key looked "loaded" but SSH auth stalled right
after "Server accepts key", and no `ssh-add` command could clear the phantom listing. That
forced two design changes beyond the original plan: a **signability check** (so "loaded"
means usable, not merely listed) and a **switch to a plain OpenSSH ssh-agent** (bypassing
gcr for SSH).

## What Changes

- **New mipbar status indicator (`SshKey`).** A small, always-visible **four-state** widget
  in the bar's `end` cluster (alongside Camera/Screenshare/SystemMonitor) showing whether
  the user's ed25519 key is usable in the ssh-agent:
  - **loaded** — fingerprint present AND the agent can sign (`ssh-add -T`) → open padlock,
    green.
  - **unloaded** — agent reachable but the fingerprint is absent → closed padlock, amber.
  - **stale** — fingerprint listed but the agent cannot sign → lock-with-alert, red.
  - **no-agent** — agent unreachable (`ssh-add -l` exit code 2) → grey ✖.
  - (The loaded/unloaded icons are deliberately open-vs-closed padlocks: open = the key is
    unlocked and available, closed = it is locked away.)
- **Signability, not mere listing, defines "loaded".** The poll runs a `timeout`-bounded
  `ssh-add -T` so a hung agent cannot stall it; a listed-but-can't-sign key is reported as
  `stale`.
- **Fingerprint-based matching.** The "my key" predicate is computed at runtime from
  `~/.ssh/id_ed25519.pub` via `ssh-keygen -lf`, so it survives key rotation and comment
  mismatch. It is not hardcoded.
- **Click-through popover with Load/Unload.** Clicking opens a popover that names the
  current state and offers the applicable action: **Load** (`ssh-add ~/.ssh/id_ed25519`,
  surfacing a passphrase prompt) when unloaded/stale, **Unload** (`ssh-add -d`) when loaded,
  and no action when no-agent. The loaded popover also shows the fingerprint. Actions
  re-poll immediately and are guarded so each click fires at most one prompt.
- **Passphrase prompt scoped to the widget.** The askpass env (`SSH_ASKPASS`,
  `SSH_ASKPASS_REQUIRE=force`) is set **inline** on the widget's `ssh-add` — not as
  session-wide variables — so the GUI popup appears only from the widget; a plain terminal
  `ssh`/`ssh-add` keeps its normal tty prompt. A Hyprland window rule floats/centers the
  askpass window.
- **Plain OpenSSH ssh-agent instead of gcr.** The session uses a plain `ssh-agent`
  (`services.ssh-agent`) for `SSH_AUTH_SOCK`; gcr's ssh-agent socket/service is masked.
  gnome-keyring stays for the Secret Service (Signal, granted-aws, etc.) — only its SSH
  role is dropped.
- **Polling.** State is refreshed on a poll (≈5s), consistent with the other status
  indicators. `ssh-add -l`/`-T` and `ssh-keygen -lf` are local and cheap.

## Capabilities

### New Capabilities

- `mipbar-ssh-key-indicator`: A four-state mipbar indicator that reports whether the user's
  ed25519 key (matched by fingerprint, verified by signability) is usable in the ssh-agent,
  with a click-through popover to load or unload it, backed by a plain OpenSSH ssh-agent.

## Impact

- `packages/mipbar/widget/SshKey.tsx`: new widget — manual `createState` + a `timeout`-bounded
  poll script emitting loaded/unloaded/stale/noagent; a `menubutton` popover with
  state-aware Load/Unload; an in-flight guard; inline askpass env on the Load command.
- `packages/mipbar/widget/Bar.tsx`: import `SshKey` and add `<SshKey />` to the `end` `<box>`.
- `packages/mipbar/style.scss`: `.SshKey` state colors (green/amber/red/grey) and
  `.SshKeyPopover` styling.
- `packages/mipbar/env.d.ts` + `flake.nix`: declare and inject an `ASKPASS` define so the
  standalone askpass path is baked into the bundle at build time.
- `modules/USERS/pim/programs/mipbar/default.nix`: `services.ssh-agent.enable`; set
  `systemd.user.sessionVariables.SSH_AUTH_SOCK`; mask gcr's ssh-agent socket/service via
  `mkOutOfStoreSymlink "/dev/null"`; install `pkgs.lxqt.lxqt-openssh-askpass`. (No session
  `SSH_ASKPASS*` — that is set inline in the widget.)
- `modules/USERS/pim/programs/hyprland/hypr/rules.conf`: window rule (Hyprland 0.53+ syntax,
  `match:title …, float on, center on`) to float/center the askpass popup.
- `ssh-keygen`/`ssh-add` were confirmed already on the bar's PATH (systemwide), so no
  `pkgs.openssh` was needed.
