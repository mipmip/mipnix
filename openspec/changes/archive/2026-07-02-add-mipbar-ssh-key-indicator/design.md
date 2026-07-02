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
SSH_AUTH_SOCK=/run/user/1000/gcr/ssh        (gnome-keyring gcr agent — later replaced)
ssh-add -l → 256 SHA256:99MlTK/GhZ3bAsQBDeB4+oAvqy5cpHxRPy+MN6JRRVM pim@ojs (ED25519)
~/.ssh/id_ed25519.pub fingerprint: SHA256:99MlTK/GhZ3bAsQBDeB4+oAvqy5cpHxRPy+MN6JRRVM
~/.ssh/id_ed25519.pub comment:     post@pimsnel.com   ← differs from agent's "pim@ojs"
```

Critically, the original gcr agent would keep a passphrase-protected key in its `ssh-add -l`
listing while being **unable to sign** with it: `ssh-add -T` hung, SSH auth stalled right
after "Server accepts key", and no `ssh-add -d`/`-D`/re-add/agent-restart cleared the
phantom listing. So "listed" did not mean "usable" — the design accounts for that with a
signability check (the `stale` state) and, ultimately, by replacing gcr with a plain
OpenSSH ssh-agent (see Decisions).

## Goals / Non-Goals

**Goals:**
- A glanceable, always-present indicator of whether the user's ed25519 key is **usable** in
  the agent (present AND signable), not merely listed.
- Distinguish four states: loaded, unloaded, stale (listed but can't sign), no-agent.
- Identify "my key" robustly across machines and key rotation (fingerprint, not comment).
- One-click load/unload from a popover, with the passphrase prompt scoped to the widget.
- A signing agent that reliably works with a passphrase-protected key (plain ssh-agent).
- Fit the existing mipbar widget pattern, file layout, and `end`-cluster styling.

**Non-Goals:**
- Handling multiple personal keys or arbitrary key sets (scope is the single
  `~/.ssh/id_ed25519`).
- A full key-management UI (listing, adding/removing arbitrary keys). Load/Unload only.
- Forwarding-agent / per-host agent status.
- Removing gnome-keyring's Secret Service role (kept for Signal, granted-aws, etc.); only
  its SSH role is dropped.

## Decisions

### Four-state, always visible (not hide-when-idle)

Unlike `Camera` (which hides when no camera is in use), the SshKey indicator is **always
visible** and changes icon/color across four states. Rationale: the user wants a
security-posture glance — the *absence* of a usable key is itself meaningful. The four
states map to distinct icons and CSS classes:

| State    | Condition                                             | Icon              | CSS class   |
|----------|-------------------------------------------------------|-------------------|-------------|
| loaded   | `<fp>` listed AND `ssh-add -T` signs                  | 󰿆 open padlock    | `.loaded`   |
| unloaded | agent reachable, `<fp>` absent                        | 󰌾 closed padlock  | `.unloaded` |
| stale    | `<fp>` listed but `ssh-add -T` fails/times out        | 󰦝 lock-with-alert | `.stale`    |
| no-agent | `ssh-add -l` exit code 2 (cannot connect)             | 󰗤 cross           | `.noagent`  |

**Icon polarity (open = loaded):** the open padlock means "the key is unlocked and
available"; the closed padlock means "locked away / not loaded". (This is the reverse of an
early draft that used a solid lock for loaded.) Colors: loaded = green, unloaded = amber,
stale = red, no-agent = grey.

### Signability defines "loaded", not mere listing

The poll derives the target fingerprint from the pubkey file, checks it is in the agent
listing, then confirms the agent can actually sign with it — bounded by `timeout` so a hung
agent cannot stall the 5s poll:

```bash
fp=$(ssh-keygen -lf ~/.ssh/id_ed25519.pub 2>/dev/null | awk '{print $2}')
out=$(ssh-add -l 2>/dev/null); rc=$?
if   [ "$rc" -eq 2 ]; then echo noagent
elif ! printf '%s\n' "$out" | grep -qF "$fp"; then echo unloaded
elif timeout 4 ssh-add -T ~/.ssh/id_ed25519.pub >/dev/null 2>&1; then echo loaded
else echo stale
fi
```

**Why the sign check:** the gcr agent kept the key listed but could not sign with it — SSH
would offer the key, the server would accept it, then auth would hang. `ssh-add -l` alone
therefore over-reports "loaded". `ssh-add -T` (bounded by `timeout`) distinguishes a
genuinely usable key from a `stale` phantom listing.

**Why fingerprint, not comment:** the file comment and the agent's reported comment can
differ, so comment matching is unreliable. The fingerprint is identical in both and stable
across machines.

**Why derive at runtime, not hardcode:** survives key rotation; the widget keeps working if
the user regenerates `id_ed25519` without any code edit.

**ssh-add exit codes** (for the no-agent branch): `0` = at least one identity, `1` = agent
reachable but no identities, `2` = unable to contact the agent.

### Click-through popover with Load / Unload

Rather than a bare click action, the widget is a `menubutton` whose popover reports the
current state in words and offers the applicable action:
- **unloaded / stale** → **Load**: `ssh-add ~/.ssh/id_ed25519`, surfacing a passphrase
  prompt via the standalone askpass GUI.
- **loaded** → **Unload**: `ssh-add -d ~/.ssh/id_ed25519`; the popover also shows the
  fingerprint.
- **no-agent** → no action button.

State is managed with `createState` (not `createPoll`, whose accessor has no public re-poll
method): a `refresh()` runs the poll script once and sets the state, driven by an `interval`
for the periodic poll and called again after every Load/Unload so the icon/button update
immediately (both on success and failure — a failed Unload re-reads reality rather than
lying). An `inFlight` guard ensures each activation fires at most one `ssh-add` (and thus at
most one passphrase popup), even on rapid clicks.

**askpass scoped to the widget (not the session):** `SSH_ASKPASS` / `SSH_ASKPASS_REQUIRE`
are set **inline** on the widget's `ssh-add` command, not as session variables. An earlier
attempt exported `SSH_ASKPASS_REQUIRE=force` session-wide, which made *every* terminal
`ssh`/`ssh-add` pop the GUI instead of prompting on the tty. The standalone askpass path is
baked into the bundle at build time (an `ASKPASS` `ags bundle -d` define, declared in
`env.d.ts`), so the widget does not depend on the session exporting `SSH_ASKPASS`. A Hyprland
window rule floats/centers the askpass window (it reports an empty class, so the rule matches
on its title using the 0.53+ `match:title …, float on, center on` syntax).

Note the earlier gcr-askpass dead end: gcr's own askpass (`gcr-ssh-askpass` /
`gcr4-ssh-askpass`) refuses standalone invocation ("not meant to be run directly"), so it
cannot serve as a generic `SSH_ASKPASS` — hence a standalone askpass
(`pkgs.lxqt.lxqt-openssh-askpass`).

### Plain OpenSSH ssh-agent instead of gcr

The root cause of the `stale`/hang problem was gcr-ssh-agent forwarding to gnome-keyring,
which held the passphrase-protected key unsignably and would not let `ssh-add` mutate its
view. The fix is to bypass gcr for SSH entirely:
- Enable `services.ssh-agent` (a plain OpenSSH `ssh-agent` on `$XDG_RUNTIME_DIR/ssh-agent`).
- Point the whole graphical session at it via `systemd.user.sessionVariables.SSH_AUTH_SOCK`
  and a Hyprland `env` line (HM's `services.ssh-agent` only sets it for login shells).
- Mask gcr's `gcr-ssh-agent.socket`/`.service` (a `mkOutOfStoreSymlink "/dev/null"` — a
  plain `source = "/dev/null"` fails HM with "unsupported type" because it tries to copy the
  device node).
- Keep gnome-keyring for the Secret Service (`org.freedesktop.secrets` — used by Signal's
  `--password-store=gnome-libsecret`, granted-aws, etc.); only its SSH role is dropped.

A plain agent starts empty and signs normally, so the widget shows `unloaded` at login and
Load actually works.

### Poll interval ≈ 5s

Consistent with `Camera` (5s). `ssh-add -l` + `ssh-keygen -lf` are local and inexpensive,
so 5s gives prompt feedback without measurable cost.

## Risks / Trade-offs

- **[Resolved] askpass routing.** gcr's own askpass cannot be used as a generic
  `SSH_ASKPASS` (refuses standalone invocation), and no askpass is on PATH by default.
  *Resolution:* a standalone askpass (`pkgs.lxqt.lxqt-openssh-askpass`) whose path is baked
  into the bundle and set inline on the widget's `ssh-add` (not session-wide).

- **[Resolved] gcr agent could not sign.** The gcr agent listed the key but hung on signing
  and refused `ssh-add -d`/`-D`. *Resolution:* replace it with a plain OpenSSH ssh-agent and
  mask gcr's ssh-agent; also detect the residual case as the `stale` state.

- **[Trade-off] session-wide agent switch.** Repointing `SSH_AUTH_SOCK` to a plain agent and
  masking gcr affects all SSH in the session, not just the widget. Accepted: it is the only
  reliable way to get a signable agent, and gnome-keyring keeps its non-SSH secrets role.
  Requires a fresh login to take effect (the session env is set at session start).

- **[Risk] hardcoded key path.** `~/.ssh/id_ed25519` is assumed to be the personal key.
  Stable for this setup; a different filename would need a one-line edit. Acceptable for a
  personal ricing config.

- **[Trade-off] always-visible vs. quiet bar.** An always-present indicator adds one icon to
  the `end` cluster even in the common "loaded" state. Chosen deliberately for the
  security-posture glance; appear-only-when-loaded (like Camera) was rejected because it
  cannot signal the unloaded state.

- **[Note] PATH for ssh tooling.** `ssh-keygen`/`ssh-add` were confirmed already on the bar's
  PATH (systemwide), so no `pkgs.openssh` was needed.

## Alternatives Considered

- **Comment / `(ED25519)`-type matching** — rejected: comment mismatch makes it fragile, and
  type-only matching would falsely match any other ed25519 key.
- **Hide-when-idle (Camera pattern)** — rejected: cannot convey the unloaded/stale states.
- **Bare click-to-load (no popover), no-op when loaded** — the original plan; replaced by a
  popover with explicit Load/Unload after a no-op click read as "broken". The popover also
  gives a place to show the fingerprint and name the state.
- **Keep gcr, repair `stale` via ssh-add / agent restart** — rejected: verified that no
  `ssh-add -d`/`-D`/re-add/agent-restart clears gcr's unsignable listing. Only a plain agent
  fixes it.
- **Fully remove gnome-keyring** — rejected: it still serves the Secret Service for Signal,
  granted-aws, and libsecret consumers. Only its SSH role is dropped.
