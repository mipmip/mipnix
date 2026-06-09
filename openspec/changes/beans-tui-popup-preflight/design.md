## Context

The `prefix + B` bind (added in the archived `tmux-beans-tui-popup` change) is:

```
bind B popup -E -w 90% -h 90% 'beans tui'
```

`-E` closes the popup the moment the command exits, so any `beans tui` failure is a silent
flash. Observed: in `technative-project-proposals` — a valid project (23 beans,
`beans check` passes) — the popup still flash-closed, and the cause is unknown because the
error was never visible.

Key behaviors of `beans` (verified):
- `beans tui --config` "searches upward for `.beans.yml`" — the project marker is
  `.beans.yml`, not merely a `.beans/` folder.
- **`beans check` exits 0 even in a non-project dir** (prints `Error: no .beans directory
  found ...` but returns 0). So its exit code is unreliable for gating.

The repo has a strong pattern of small `writeShellScriptBin` helpers (wrofi, hypr-longpress,
smg, open) for pim's tools.

## Goals / Non-Goals

**Goals:**
- The popup never silently flash-closes: on failure it shows CWD + `beans check` output and
  waits for a keypress.
- Happy path unchanged: `prefix + B` opens `beans tui`; quitting closes the popup.
- Make the technative flash-close *visible* (diagnose the real cause next time).

**Non-Goals:**
- Fixing the underlying technative crash now (we don't know it yet — this reveals it).
- Changing the key (`B`), geometry (90%×90%), or the pane-cwd behavior.
- Reworking `beans` itself.

## Decisions

### Implement as a `beans-tui-popup` script, not inline

A `writeShellScriptBin "beans-tui-popup"` holding the preflight + branch logic, called by
the bind. Matches the wrofi/smg/open pattern.

**Why**: the logic is multi-line (preflight, conditional, echo, conditional pause).
Inlining it in `bind B popup '...'` inside the Nix `''` `extraConfig` means triple-layer
escaping (Nix → tmux → bash), which is fragile. A script keeps the bind trivial and the
logic readable.

### Gate on the `.beans.yml` marker, not on `beans check` exit code

Preflight detects a project by searching upward for `.beans.yml` (replicating beans' own
resolution). `beans check`'s exit code is NOT used to decide success (it returns 0 even on
"no project").

**Why**: `beans check` exits 0 in a non-project dir — gating on it would let the script
proceed into `beans tui` and flash-close anyway (the original bug). The marker check is the
reliable signal.

**Still run `beans check`**: its OUTPUT is shown on the failure path (per the request) as
extra diagnostics, even though its exit code is ignored.

### Branch logic + lifecycle (drop `-E`)

```
echo "CWD: $PWD"
if <.beans.yml found upward>; then
  beans tui                       # happy path
  rc=$?
  if [ "$rc" -ne 0 ]; then        # tui crashed
    echo "beans tui exited with code $rc"
    beans check                   # show diagnosis
    echo "Press any key to close"; read -rn1
  fi
  # rc == 0 (normal quit) → fall through, script ends, popup closes
else
  echo "No beans project (.beans.yml) found at or above this directory."
  beans check                     # show beans' own message
  echo "Press any key to close"; read -rn1
fi
```

The bind drops `-E` so the script owns when the popup closes: clean quit → script ends →
popup closes; failure → `read` holds it open.

**Why this matches the requirements**: happy path runs `beans tui` (req 4); failure shows
CWD used + `beans check` output and pauses (req 3); only failure pauses (req 1/4).

## Risks / Trade-offs

- **[Risk] Without `-E`, a hung command keeps the popup open** → acceptable; the script
  always reaches a defined end (tui returns, or `read` waits for one key).
- **[Risk] Marker-search differs from beans' real resolution** (e.g. `BEANS_PATH` env or a
  `--beans-path`) → edge case; the common case is `.beans.yml` upward. If beans is driven
  by env/flags elsewhere, the preflight may misjudge — but it still falls through to
  showing output, never worse than the current silent flash.
- **[Trade-off] Extra `beans check` run** on every invocation → negligible cost, and it's
  the requested diagnostic.

## Migration Plan

1. Add the `beans-tui-popup` `writeShellScriptBin` (with the branch logic above) where
   pim's CLI helpers are defined; ensure it's on PATH.
2. Change `bind B` in `tmux/default.nix`: drop `-E`, call `beans-tui-popup`.
3. Build + reload tmux.
4. Verify: `prefix + B` in mipnix opens the tui and closes on quit; in a non-project dir it
   shows CWD + reason and waits for a key; in `technative-project-proposals` it now shows
   the real error/exit instead of flash-closing.

**Rollback**: revert the bind to `popup -E ... 'beans tui'` and drop the script.

## Open Questions

- None for this change. (The technative root cause remains open, but this change exists to
  reveal it, not resolve it.)
