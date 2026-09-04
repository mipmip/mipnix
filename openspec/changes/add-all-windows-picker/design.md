## Context

`Minimized.tsx` is already 90% of this widget. It has the `menubutton` + `popover` +
`For each` shape, the Hyprland signal wiring, `lookupIcon`, and the address handling.
What changes is the source query and the actions.

```
Minimized.tsx                        all-windows picker
─────────────                        ──────────────────
menubutton + popover          same
For each={items}              same
lookupIcon(class)             same
client-added/removed/moved    same signals
withHexPrefix(address)        same — and still required

source: one special workspace  ──▶   every client
action: bring-here only        ──▶   L = go-to, R = bring-here
visible: only when non-empty   ──▶   always
```

## Decisions

### Derive from the client set, never from a workspace list

This is the requirement that gives the widget its point. `Workspaces.tsx` broke by
enumerating workspace ids; a picker that enumerates workspaces to find windows would
inherit exactly the blindness it exists to compensate for. Iterate clients directly
and read each one's workspace only for context, never as a filter.

The spec states this as an observable property (`the number of rows SHALL equal the
number of clients Hyprland reports`) rather than as an implementation instruction, so
it stays checkable.

### Address normalization is not optional

`Minimized.tsx:30-34` documents the trap: AstalHyprland's `get_address()` returns the
address *without* the `0x` prefix, while `hyprctl dispatch … address:<addr>` requires
it and fails with "No such window found" otherwise. Both actions here dispatch by
address, so both need the same normalization.

### Dispatch idiom: prefer the native call

The two existing widgets disagree, and this one should pick deliberately rather than
by copy-paste:

| Widget | Idiom |
|--------------------|--------------------------------------------------------|
| `ScreenPicker.tsx` | `hyprland.dispatch("moveworkspacetomonitor", …)` |
| `Minimized.tsx` | `execAsync(["bash", "-c", "hyprctl dispatch … && …"])` |

`Minimized` needs a shell only because it chains two dispatches with `&&`. Go-to is
expected to be a single dispatch, so it can use the native `hyprland.dispatch()` and
avoid spawning a process. Bring-here needs two; sequential native dispatches over the
same IPC socket preserve ordering, so it should not need a shell either.

### Go-to is likely one dispatch, but verify

`focuswindow address:<addr>` is expected to switch to the window's workspace *and*
focus it — making go-to simpler than `Minimized`'s two-step restore. **This was not
verified during exploration**: testing it would have yanked focus on a live session.
Task 3.1 verifies it before the implementation depends on it, with the two-step
(`workspace <id>` then `focuswindow`) as the fallback.

### Special workspaces degrade rather than error

A left-click on a `special:minimized` row has no sensible destination —
`dispatch workspace special:minimized` would flash the special overlay, which is not
what "activate this window" means. Rather than hiding those rows (the list is meant
to be exhaustive) or erroring, left-click falls through to bring-here for them. The
asymmetry is confined to special workspaces and is specified, not incidental.

### Always visible

`Minimized` hides itself when empty because "nothing is minimized" is a meaningful
state. There is essentially always at least one window open, and an indicator that
appears and disappears would be harder to find than one that is always in the same
place — which matters for a widget whose whole job is being findable when something
has gone missing.

## Risks / Trade-offs

- **Overlap with `Minimized`.** Minimized windows appear in both popovers. Accepted:
  the alternative is either a non-exhaustive list, or merging the widgets, which the
  proposal puts out of scope.
- **List length.** With ten workspaces this could reach 20+ rows and become tedious
  to scan. No filter, by decision. Revisit if it actually bites.
- **Right-click is undiscoverable.** Matches the existing `Workspaces.tsx` screen
  picker, which has the same property. A tooltip on the indicator is the cheap
  mitigation if wanted.

## Relationship to `fix-workspace-zero-identity`

Independent, and neither blocks the other. That change closes the specific hole that
produced the observed lost window (workspace id 10 unreachable via `MOD+0`); this one
catches whatever falls through any remaining hole — the swipe gesture can still land
a window on workspace 11, which no allowlist covers. Landing the ws-0 fix first would
make this widget's motivating example disappear, which is fine: the requirement is
written against the general property, not that one instance.
