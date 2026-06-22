# Spike findings — tmux "zoom reading mode"

Status: **exploration only** (no implementation). Captured 2026-06-22.

## Original goal

Mirror Vim's zen-mode (`<leader>Z`, plugin `zen-mode` in `packages/mipvim`) as a
tmux feature, bound to `prefix + Shift+Z`:

1. hide all other panes
2. themed background — light mode → white bg / dark text; dark mode → dark bg / white text
3. horizontally centered text, ~80–90 char column with side padding
4. `prefix+Shift+Z` toggles state

## What the real objective turned out to be

The actual target was **reading Claude Code** in a calm centered view. Two
requirements were dropped/relaxed after spiking:

- **White-background requirement: DROPPED.** A TUI like Claude Code paints its
  own full background, so tmux can only theme the *margins*, not the content
  area. The "white page" effect doesn't work for TUIs and was judged not worth
  the instability.
- Layout stability became the dominant concern (the first spike screwed the
  window layout on return).

## Strategy A — padding panes (spike 1, `/tmp/tmux-reading-mode.sh`)

Break the active pane into its own `[reading]` window, add two themed spacer
panes left/right so the center is ~85 cols.

| Aspect | Result |
|---|---|
| save/restore via `#{window_layout}` + `select-layout` | ✅ byte-perfect round trip |
| `break-pane` to isolate the pane (hide others) | ✅ works |
| centered ~85c column + symmetric margins | ✅ works |
| per-pane themed margins via `set -p window-style 'bg=…'` | ✅ works (white/dark from `gsettings color-scheme`) |
| width guard (<100 cols → no-op) | ✅ works |
| **center pane recolor** | ❌ impossible — tmux can't repaint a program's own bg. Killed the white-bg goal for TUIs. |
| **rejoin position on return** | ⚠️ `join-pane` rejoin did not restore the exact original slot → "layout screwed" |

## Strategy C — popup (spike 2, `/tmp/tmux-reading-popup.sh` + probes)

`display-popup -E` is centered + padded by construction. But a popup runs a NEW
process; to show *your existing* pane it must attach to a session.

| Mechanism | Result |
|---|---|
| popup attaches to a **separate, pre-existing session** | ✅ **ROCK SOLID** — proven: popup showed a marker session at 85×90%, attaching session left the origin session untouched |
| **move a live pane** out → scratch session → back (`join-pane` across sessions) | ❌ **FRAGILE** — cross-session `join-pane` lost the pane in a controlled test; same failure mode that screwed the layout |
| popup attaching to the **same** session you're already in | ⚠️ tmux warns ("nest with care"); not a solid base |

### Popup toggle + the backdrop limitation (round 2)

A dedicated-session popup toggle was built (`/tmp/tmux-reading-popup-toggle.sh`,
`prefix+Shift+Z`) and tried live:

- Toggle logic works: open from a normal pane; pressing the key *inside* the
  popup detaches (the script branches on `#{client_session}` == the reading
  session). Session auto-creates on first use and persists between toggles.
- **OBSERVED BY USER:** the popup does **not hide what is behind it.** Confirmed
  against the tmux 3.6a `display-popup` flag set: `-B -C -E -k -N -b -s -S -h -w
  -x -y -T`. `-s` styles the popup box, `-S` its border — **nothing controls or
  dims the area outside the popup**, and there are **no global `popup-*` style
  options** in this build. A popup is an overlay; the live pane keeps rendering
  underneath. So the popup CANNOT satisfy "hide all other panes".

This corrects the round-1 note that the popup "hides others (overlay) ✅" — it
does not; the other panes remain visible around the box.

## The fundamental trade (proven, not theorized)

| want | popup | break-pane / padding-panes |
|---|---|---|
| centered ~85c column | ✅ native | ✅ via spacer panes |
| side padding | ✅ native | ✅ themed margins |
| **hide everything else** | ❌ shows through | ✅ truly alone |
| layout never disturbed | ✅ overlay | ⚠️ break/rejoin |
| stability | ✅ rock solid | ⚠️ see below |

**No single tmux primitive does both centered-padded AND opaque-fullscreen.**

### Multi-pane restore SCRAMBLES (proven)

Tested break-out + bring-back on a clean 3-pane throwaway window: `select-layout
"<saved>"` restored the *geometry* but reassigned panes to slots — the reading
pane (`%139`) started in the left slot and came back in bottom-right. Root cause:
`break-pane` removes the pane; `select-layout` cannot pin a *specific* pane to a
*specific* slot once it has left and re-entered. The byte-perfect round trip seen
in round 1 only held because that pane was **alone** in its window (nothing to
scramble against).

→ **The scramble vanishes when the reading target is alone in its window.**

### Live splitting can kill the controlling pane (incident)

The spike intended to validate ideas (1)/(2) below was run against the **live
attached session** instead of an isolated server. A `split-window` landed in the
pane hosting the Claude Code connection and **broke the session** (left a stray
`fish` pane `%148` in the `mipnix` window; user cleaned up manually).

→ **LESSON:** never run pane manipulation against the live session during
testing. Use an isolated server: `tmux -L spiketest -f /dev/null new-session -d`.
And the real implementation must capture pane ids up front and must not split the
pane that hosts the controlling process.

## Ideas still OPEN (untested cleanly — the validating spike crashed)

Both aim to avoid the scramble by **never letting a pane leave the window**:

1. Within the same window: add 2 spacer panes, resize the *other* real panes to
   ~zero / off-view; on toggle-off `select-layout "<saved>"`. Hypothesis: restore
   is exact because no pane ever left (select-layout can re-place panes it still
   holds). **Unverified** — must be tested on a `-L spiketest` socket.
2. Same as (1) but treat the saved layout string as source of truth; kill only
   spacers, then `select-layout`. Same dependency: no pane leaves.

## Conclusion / current state

- **White-background:** dropped (TUIs paint their own bg; tmux can't recolor).
- **Popup:** centered + stable, but **can't hide the backdrop** → fails req #1.
  Viable only if "hide everything" is relaxed to "overlay on top".
- **Padding-panes (break-out):** hides others, but multi-pane restore scrambles;
  clean only when the target is alone in its window.
- **Chosen direction (user):** implement the **padding-panes** solution and try
  to fix the layout restore via ideas (1)/(2) — *never leave the window*. These
  remain UNVERIFIED; validate on an isolated `-L spiketest` server first.

## Open questions for a future proposal

- Does idea (1)/(2) actually restore exact on a multi-pane window? (test isolated)
- Behaviour when target is alone in window (clean) vs multi-pane (needs 1/2).
- `prefix+Shift+Z` (capital) chosen, pairs with native `prefix+z`.
- Packaging: `writeShellScriptBin` in `modules/USERS/pim/programs/tmux/`,
  bound in `extraConfig` (matches the `beans-tui-popup` pattern).
- No `.beans` task exists for this yet (per CLAUDE.md, a proposal would link one).

## Scratch artifacts (throwaway, `/tmp`, gone on reboot)

- `/tmp/tmux-reading-mode.sh` — Strategy A spike 1 (break-out + themed margins)
- `/tmp/tmux-reading-popup.sh` — popup move-pane variant (fragile)
- `/tmp/tmux-reading-popup-toggle.sh` — dedicated-session popup toggle (round 2)
