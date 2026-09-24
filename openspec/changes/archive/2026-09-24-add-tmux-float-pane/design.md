## Context

See proposal.md for motivation. What the approach has to work within:

- tmux 3.6a, so `display-popup -b` and `-c target-client` are available.
- Custom bindings come from `flake.hotkeys` filtered to the tmux target, and
  every entry is emitted twice: as a `bind` line and as a `prefix + ?` menu row.
  That second emitter is what makes `+` and `-` awkward.
- Launcher scripts in this module are `writeShellScriptBin` in the module's
  `let` block, referenced by bare name from the binding, as `beans-tui-popup`,
  `nebula-ssh` and `drs-switch` already are.
- One client is attached, to one of ten sessions. A server-global float is
  therefore a singleton in practice as well as in the design.
- `f` is tmux's `find-window -Z` and `-` is `delete-buffer`; both are defaults
  worth keeping. `F` and `+` are unbound.

## Goals / Non-Goals

**Goals:**

- Exact restore, not an equivalent layout.
- The pane can never be destroyed by the toggle.
- The width keys keep their normal meaning outside the float.

**Non-Goals:**

- More than one float at a time.
- Moving the popup, changing its height, or a size lock. tmux-floax has all of
  that for a different feature; this one is zoom with margins.
- Repeat (`bind -r`) on the width keys. The popup is reopened on each step, and
  the repeat state does not survive that.

## Decisions

### Swap the pane into a hidden session, not a copy of it

A popup attaches to a session; it cannot host a pane that already exists
elsewhere. So the pane moves, and something has to hold its place.

```
  before                     floating                    after
  ┌────┬────┐                ┌─────────┐                 ┌────┬────┐
  │    │ P  │                │placehold│  window         │    │ P  │
  │    ├────┤   swap -d      │ (zoomed)│                 │    ├────┤
  │    │    │  ─────────►    └─────────┘                 │    │    │
  └────┴────┘                ┌─────────┐  popup          └────┴────┘
                             │    P    │  on _float
   layout 6740                └─────────┘                 layout 6740
                              layout e740
```

Verified on a spike before writing this: `window_layout` reads
`6740,200x50,...,53,...,54` before, `e740,...,55,...,54` while floating with the
placeholder in the pane's slot, and `6740,...,53,...,54` again afterwards. Same
checksum, same geometry, same pane ids. The process inside the pane was still
running and its output still in the scrollback.

Rejected: a second pane running the same program. It is not the same pane, the
scrollback does not come with it, and anything stateful is simply lost.

Rejected: `resize-pane -Z` with padding. tmux has no notion of a margin around a
zoomed pane; zoom is edge to edge by construction.

### The placeholder is zoomed, which is what blanks the background

The placeholder lands in the pane's exact slot, so the window behind the popup
would otherwise show the layout with one blank rectangle in it, which reads as a
glitch. Zooming the placeholder makes the whole window blank, so the popup is
unambiguously the thing in front. It also means the restore has to unzoom first,
which is one condition on `#{window_zoomed_flag}`.

### Kill the hidden session only once it holds the placeholder

The dangerous ordering is the obvious one: swap back, then `kill-session`. If
the swap does not take effect, the session still holds the user's pane and the
kill destroys it along with whatever was running in it.

So the kill is guarded: it runs only when the session's remaining pane is the
placeholder id that was stored at float time. A restore that did not complete
leaves the session alive and the pane recoverable by pressing the toggle again.

This is the one place in the feature where a mistake is not recoverable, which
is why it is a requirement rather than a comment.

### `menu = false` in the registry rather than a second place for bindings

`+` and `-` do nothing outside the float, and the menu is a flat list with no
way to say so. Worse, the menu row's name starts with the key, and tmux renders
a name beginning with `-` as dim and unselectable, so the `-` entry would appear
as a dead row. From the tmux manual: "If the name begins with a hyphen (-), then
the item is disabled (shown dim) and may not be chosen."

Three options were considered:

| | approach | why not |
|---|---|---|
| A | register all three as normal entries | `-` renders as a dead row; the conditional command has to survive `{ }` quoting |
| B | register `F`, write `+`/`-` as raw `extraConfig` | reintroduces the second list of bindings the registry exists to abolish |
| C | add `menu = false` | one field, and it answers the general case |

C, because "this key only means something in a context the menu cannot show" is
a category rather than a quirk of this feature, and because it makes the quoting
problem not arise instead of solving it.

The leading-hyphen case is also made a build failure rather than left as a trap:
a key that would produce a disabled row must be marked out of the menu or the
build stops. Otherwise the next person to register `-` gets a dim row and no
explanation.

### The width keys are conditional bindings with the old binding as the else

```
  bind - if -F '#{==:#{session_name},_float}' \
            'run-shell -b "<resize> -10"' \
            'delete-buffer'
```

Tested: tmux 3.6a accepts this and reports it back as
`if-shell -F "..." "run-shell -b \"...\"" delete-buffer`. The condition works
because the key press arrives from the popup's own client, whose session is the
hidden one.

`delete-buffer` is what `-` is bound to today, so the fallback is the tmux
default rather than an invention. `+` has no binding to fall back to, so its
conditional has no else branch.

### Resize is detach and reopen, targeting the stored outer client

`display-popup` has no resize. The width changes by closing the popup and
opening a new one, which is why the outer client's tty is stored at float time:
the key press arrives from the popup's client, and reopening against that client
would put the popup inside the thing being replaced.

The fragile part is the gap between the detach and the reopen. A fixed sleep is
a guess; the reopen should instead wait for the hidden session to have no client
attached, bounded by a short timeout, so that a slow machine does not leave the
pane floating with no popup. The failure is recoverable either way, since the
toggle still restores, but a retry turns a visible glitch into nothing at all.

### `F` for the toggle

`f` is `find-window -Z`, which is worth more than the convenience of a
mnemonic; `F` is unbound and reads the same. `+` and `-` are the natural pair
for width and are free enough, `-` behind its fallback.

## Risks / Trade-offs

- **The kill could destroy the pane.** → Guarded by identity: the session is
  removed only when the pane left in it is the placeholder. Stated as a
  requirement with its own scenario.
- **One float for the whole server.** → True, and acceptable while one client is
  attached, since only one session can be in view. Floating in a second session
  while a float is open would take the restore path for the first. A
  per-session session name is a small change if a second client ever appears.
- **The resize race.** → Wait for the client to go rather than sleep. Worst case
  the pane floats with no popup and the toggle brings it back.
- **A registry field added for one feature.** → It is a general category and it
  is opt-in, so every existing entry behaves exactly as before.
- **The status bar toggle on `b` sets `status` globally.** → The hidden session
  sets `status off` on itself, which is session-scoped and wins, but the two
  touch the same option and are worth checking together once.

## Open Questions

- Whether the float should eventually remember a per-application width, so a log
  opens wide and a REPL narrow. It changes nothing in the specs or the task
  breakdown, since the stored width is already a single option that a later
  change could key differently.
