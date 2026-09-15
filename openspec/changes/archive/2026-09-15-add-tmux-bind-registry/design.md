## Context

See proposal.md, Why.

Everything happens in one file, `modules/USERS/pim/programs/tmux/default.nix`.
Its `extraConfig` is a single here-string of tmux commands, with the custom
bindings scattered through it. The three launcher scripts in the same file
(`beans-tui-popup`, `nebula-ssh`, `drs-switch`) are `writeShellScriptBin`
derivations referenced from those bindings and are not affected.

What is bound today, taken from a live `tmux list-keys` diffed against a
`tmux -f /dev/null` server (24 lines differ, of which these are the ones this
config actually declares):

| Key   | Action                                 | Kind      |
| ----- | -------------------------------------- | --------- |
| `S`   | smug session picker (`smg`)            | popup     |
| `G`   | huphop repo switcher                   | popup     |
| `T`   | `tj` picker                            | popup     |
| `B`   | beans TUI (`beans-tui-popup`)          | popup     |
| `D`   | beandex                                | popup     |
| `H`   | nebula ssh picker                      | popup     |
| `R`   | dirty-repo-scanner (`drs --multiplex`) | popup     |
| `P`   | shell at the pane's path               | popup     |
| `O`   | open the pane's path in the file manager | run-shell |
| `s`   | choose-tree by name                    | native    |
| `b`   | toggle the status bar                  | run-shell |
| `;`   | last pane, zoomed                      | native    |
| `Tab` | last window                            | native    |
| `u`   | urlview over the pane                  | split     |

The remaining 10 differing lines are tmux defaults that gpakosz's
`_apply_bindings` rewrites in place (adding `-c "#{pane_current_path}"` to the
split and mouse-menu bindings). They are not declared here and do not belong in
the menu, which is the first argument against deriving the list at runtime.

## Goals / Non-Goals

**Goals:**

- One declaration per binding, feeding both the `bind` line and the help entry.
- Help that is navigable and can act, not a dump.
- No behaviour change to any existing key.
- No new runtime dependency.

**Non-Goals:**

- Listing tmux defaults, `tmux-sensible`, or copy-mode bindings.
- Context-sensitive entries. Rejected below.
- Making the menu searchable. The fzf route is a renderer swap the registry
  keeps cheap, and it is not needed at fourteen entries.
- Touching the launcher scripts or the `.tmux/gpakosz.*` files.

## Decisions

### Ground rules established by spike, not by reading the manual

Four questions decided the design, all measured on tmux 3.6a against throwaway
servers with a real client attached over a pty.

**1. A popup cannot open a popup.** From inside a `display-popup -E`, running
`tmux display-popup` again exits 0 and does nothing at all:

```
   popup open on client
          │
          ▼
  tmux display-popup -E ...
          │
          ▼
   exit 0, nothing happens        (measured: the inner command never ran)
```

Nine of the fourteen bindings are popups, so an fzf-in-a-popup picker would have
silently failed on exactly the entries that matter, while reporting success.
This is what rules out the obvious design.

**1b. `;` survives in the menu only when single-quoted.** Of `;`, `\;`, `';'`,
`";"`, `"\;"` and `'\;'` passed as a menu accelerator, only `'\;'` parses.
Every other form ends the `display-menu` command at that argument, so tmux
accepts a truncated menu without a word of complaint and every entry after `;`
disappears. The bind line wants the bare `\;` instead.

**2. A `display-menu` entry can open a popup.** The menu closes first, then the
command runs against a client with no overlay. Measured working for both a
`display-popup` entry and a `run-shell` entry.

**3. The menu already behaves the way the feature is specified.** `Enter` fires
the highlighted entry, `Up`/`Down` move and wrap, `Escape` closes without
firing, and an entry's accelerator key fires it directly. Nothing has to be
built for the navigation requirements.

**4. Conditional entries are not trustworthy.** tmux dims an entry whose name
starts with `-`, and the mouse menu generates that dash from a format
conditional. With a pure tmux format (`#{?#{==:1,2},,-}`) it dims reliably. With
a shell substitution (`#(printf -)`) the same entry was dimmed on the first
open and live on the second, because `#()` is evaluated asynchronously and
cached.

### No context-sensitive dimming

Follows from spike 4. Every plausible condition here is a filesystem question
(is there a `.beans.yml` above the cwd, are there dirty repos, is there a smug
config), which only a shell can answer, and shell answers in a menu are stale or
racy. A launcher that sometimes refuses to launch for no visible reason is worse
than one that always tries.

The existing convention handles it better anyway: `beans-tui-popup` already
detects a missing beans project, prints the cwd and `beans check` output, and
waits for a keypress instead of flash-closing. Bad context is the launcher's
business. The menu stays dumb.

### The accelerator is the real key

Each entry is registered under the key it is bound to, so `S` in the menu runs
what `prefix + S` runs. The menu is then not a second interface to learn: arrow
and `Enter` when the key has been forgotten, the key itself when it has not, and
using it teaches its own obsolescence.

This costs nothing, since both the accelerator and the `bind` line read the same
field of the same registry entry.

### The menu entry runs the command, not the key

tmux has no "invoke this binding" command. `send-keys` writes to the pane's
process and never reaches tmux's key handling, so the menu cannot re-dispatch
`prefix + S`. Both consumers therefore emit the same `cmd` string. There is one
definition and no second code path to drift.

### `display-menu` over an fzf popup

| | `display-menu` | fzf in a popup |
| --------------------- | ------------------------- | ---------------------------------- |
| Opens popup entries   | yes                       | no, silent no-op (spike 1) |
| Navigate, Enter, Escape | native                  | native to fzf |
| Fuzzy filter          | no                        | yes |
| Extra dependency      | none                      | fzf, plus a deferred-execution dance |
| Failure mode          | visible                   | silent success |

The fzf route can be made to work by having the picker write the chosen command,
then waiting for the picker's own pid to exit before `tmux source-file` runs it
(measured working). That is real machinery guarding a silent failure mode, to
buy filtering over fourteen entries. Not now.

Note that gpakosz's `_apply_bindings` already round-trips `tmux list-keys`
output back through `tmux source-file`, so that mechanism is not exotic here if
the fzf route is ever wanted.

### Grouping

The seven popup tools are one group, the tmux utility bindings (`s`, `b`, `;`,
`Tab`, `O`, `u`) another, separated by an empty menu entry. They are different
kinds of thing: one launches an application, the other nudges tmux. tmux renders
an empty entry as a horizontal rule, so the grouping costs one registry field.

## Risks / Trade-offs

- **The menu is bounded by the client height.** Measured with the shipped
  registry of 13 entries: the menu opens and works down to a 16-row client, and
  at 14 rows `display-menu` silently does nothing. Each entry added raises that
  floor by one row. Mitigation: the registry is the constant, so the ceiling is
  hit by swapping the renderer, not by rewriting the bindings.
- **`;` is tmux's command separator.** Passing a bare `;` as a menu accelerator
  fails with `unknown command` (measured). Both emitters must escape it, and the
  verification has to cover that entry specifically.
- **A description must never start with `-`.** tmux parses such a name as a flag
  (`unknown flag`), and it is also the dimming marker. The helper should not
  accept it.
- **A description must not contain an apostrophe.** The menu name is
  single-quoted and tmux offers no escape inside single quotes, so an apostrophe
  closes the name early and silently swallows the entries after it. Found by
  writing "the pane's path" in a description during implementation. Both this
  and the leading dash are rejected at eval time.
- **`prefix + ?` no longer dumps `list-keys`.** Deliberate. `tmux list-keys`
  from a shell is unaffected.
- **The registry can drift from reality in one direction only:** a binding added
  to `extraConfig` by hand bypasses the menu. That is a review habit, not a
  mechanism, and it fails safe (the key works, it is just unlisted).
