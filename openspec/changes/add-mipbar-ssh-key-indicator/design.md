## Context

mipbar is an Astal/AGS (GTK4 + TypeScript/JSX) bar. Its source lives in
`packages/mipbar` and is symlinked into `~/.config/mipbar` via the "ricing mode"
home-manager mechanism (`programs.hm-ricing-mode.apps.mipbar`). Widgets live in
`packages/mipbar/widget/` and are composed in `Bar.tsx`, which lays out a `centerbox`
with `start` / `center` / `end` boxes. The `end` box currently holds, in order: `Tray`,
the clock menubutton, `Camera`, `Screenshare`, `SystemMonitor`, `QuickSettings`.

Status widgets follow a consistent pattern (see `Camera.tsx`, `SystemMonitor.tsx`):
a `createPoll(initial, intervalMs, ["bash","-c", "…"])` produces a reactive value, and
the JSX binds `visible` / `tooltipText` / labels to derivations of that value. Actions use
`execAsync` (e.g. Camera focuses the using window via `hyprctl`).

Observed environment at exploration time:

```
SSH_AUTH_SOCK=/run/user/1000/gcr/ssh        (gnome-keyring gcr agent)
ssh-add -l → 256 SHA256:99MlTK/GhZ3bAsQBDeB4+oAvqy5cpHxRPy+MN6JRRVM pim@ojs (ED25519)
~/.ssh/id_ed25519.pub fingerprint: SHA256:99MlTK/GhZ3bAsQBDeB4+oAvqy5cpHxRPy+MN6JRRVM
~/.ssh/id_ed25519.pub comment:     post@pimsnel.com   ← differs from agent's "pim@ojs"
```

The gcr agent unlocks keys lazily (on first SSH use), so whether the key is already loaded
varies through a session — exactly the state this indicator exposes.

## Goals / Non-Goals

**Goals:**
- A glanceable, always-present indicator of whether the user's ed25519 key is in the agent.
- Distinguish three states: loaded, unloaded (agent up), no-agent (unreachable).
- Identify "my key" robustly across machines and key rotation (fingerprint, not comment).
- One-click load of the key when it is not loaded, via the existing gcr passphrase prompt.
- Fit the existing mipbar widget pattern, file layout, and `end`-cluster styling.

**Non-Goals:**
- Managing or configuring the ssh-agent / gnome-keyring itself.
- Handling multiple personal keys or arbitrary key sets (scope is the single
  `~/.ssh/id_ed25519`).
- A full key-management UI (listing, adding/removing arbitrary keys). Click-to-load only.
- Forwarding-agent / per-host agent status.

## Decisions

### Tri-state, always visible (not hide-when-idle)

Unlike `Camera` (which hides when no camera is in use), the SshKey indicator is **always
visible** and changes icon/color across three states. Rationale: the user wants a
security-posture glance — the *absence* of a loaded key is itself meaningful information,
which a hide-when-idle widget cannot convey. The three states map to distinct icons and
CSS classes:

| State    | Condition                                   | Icon      | CSS class  |
|----------|---------------------------------------------|-----------|------------|
| loaded   | `ssh-add -l` output contains `<fp>`         | 🔑 (solid)| `.loaded`  |
| unloaded | agent reachable, `<fp>` absent              | 🔓 (open) | `.unloaded`|
| no-agent | `ssh-add -l` exit code 2 (cannot connect)   | ✖         | `.noagent` |

### Fingerprint matching, computed at runtime

The poll derives the target fingerprint from the pubkey file, then greps the agent listing
for it:

```bash
fp=$(ssh-keygen -lf ~/.ssh/id_ed25519.pub 2>/dev/null | awk '{print $2}')
out=$(ssh-add -l 2>/dev/null); rc=$?
if   [ "$rc" -eq 2 ]; then echo noagent
elif printf '%s\n' "$out" | grep -qF "$fp"; then echo loaded
else echo unloaded
fi
```

**Why fingerprint, not comment:** the file comment (`post@pimsnel.com`) and the agent's
reported comment (`pim@ojs`) differ, so comment matching is unreliable. The fingerprint is
identical in both and stable across machines.

**Why derive at runtime, not hardcode:** survives key rotation; the widget keeps working if
the user regenerates `id_ed25519` without any code edit.

**ssh-add exit codes** (used for the no-agent branch): `0` = at least one identity, `1` =
agent reachable but no identities, `2` = unable to contact the agent.

### Click-to-load via ssh-add

The click handler branches on the current polled state:
- **unloaded** → `execAsync("SSH_ASKPASS_REQUIRE=force ssh-add ~/.ssh/id_ed25519")`, which
  prompts for the passphrase through a **standalone askpass** and adds the key.
- **loaded** / **no-agent** → no-op (nothing to add, or no agent to add into).

**Implementation note (askpass, resolved during the spike):** gcr's own askpass
(`gcr-ssh-askpass` / `gcr4-ssh-askpass`) refuses standalone invocation ("this program is
not meant to be run directly") and only works when driven by gcr's own prompter — so it
cannot be used as a generic `SSH_ASKPASS`. Setting `SSH_ASKPASS_REQUIRE=force` alone fails
with `ssh_askpass: exec(): No such file or directory` because no askpass is on PATH.
Resolution: the mipbar home-manager module pins a standalone askpass
(`pkgs.lxqt.lxqt-openssh-askpass`) via `home.sessionVariables.SSH_ASKPASS` (with
`SSH_ASKPASS_REQUIRE=force`), which the detached bar process inherits.

After the load resolves, the widget may force an immediate re-poll so the icon flips to
loaded without waiting up to one poll interval (nice-to-have, not required).

### Poll interval ≈ 5s

Consistent with `Camera` (5s). `ssh-add -l` + `ssh-keygen -lf` are local and inexpensive,
so 5s gives prompt feedback without measurable cost.

## Risks / Trade-offs

- **[Risk] askpass routing under gcr.** *(Resolved by the spike.)* `ssh-add` invoked from
  the detached mipbar process has no controlling tty; the passphrase prompt must come from
  an askpass. The spike found that gcr's own askpass cannot be used as a generic
  `SSH_ASKPASS` (it refuses standalone invocation), and no askpass is on PATH by default.
  *Resolution:* pin a standalone askpass (`pkgs.lxqt.lxqt-openssh-askpass`) and set
  `SSH_ASKPASS` + `SSH_ASKPASS_REQUIRE=force` via the mipbar module's
  `home.sessionVariables`, inherited by the bar. The considered fallbacks (dummy ssh
  connection for gcr auto-load; informational-only widget) were therefore not needed.

- **[Risk] PATH for ssh tooling.** The bar must have `ssh-keygen` and `ssh-add` on PATH.
  *Mitigation:* verify during implementation; if absent, add `pkgs.openssh` to the mipbar
  module's `home.packages` (the same place `brightnessctl`/`socat` are pinned).

- **[Risk] hardcoded key path.** `~/.ssh/id_ed25519` is assumed to be the personal key.
  Stable for this setup; documented in the widget. A different filename would need a one-line
  edit. Acceptable given this is the user's personal ricing config.

- **[Trade-off] always-visible vs. quiet bar.** An always-present indicator adds one icon to
  the `end` cluster even in the common "loaded" state. Chosen deliberately for the
  security-posture glance; the alternative (appear-only-when-loaded, like Camera) was
  considered and rejected because it cannot signal the unloaded state.

## Alternatives Considered

- **Comment / `(ED25519)`-type matching** — rejected: comment mismatch makes it fragile, and
  type-only matching would falsely match any other ed25519 key.
- **Hide-when-idle (Camera pattern)** — rejected: cannot convey the "agent up but key not
  loaded" state, which is the main thing the user wants to see.
- **Informational only (no click)** — kept as a fallback if askpass routing proves
  unreliable, but click-to-load is the preferred behavior.
