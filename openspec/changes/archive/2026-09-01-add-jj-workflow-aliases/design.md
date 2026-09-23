## Context

Two everyday jj motions need shortcuts. The constraint that shapes the whole design:
**jj's native `[aliases]` map one alias name to exactly one subcommand plus arguments —
they are not shell aliases and cannot chain with `&&` or run arbitrary shell.** So the
work splits across two config surfaces.

```
  motion                         mechanism that can express it
  ────────────────────────────   ──────────────────────────────────────────
  describe -m … && new           built-in `jj commit` (already exists)
  the "&& new" chaining itself    impossible as a jj alias → fish abbr
  bookmark move (single subcmd)   jj [aliases]  →  tug
  tug && git push (chained)       impossible as a jj alias → fish abbr
```

## Decisions

### Decision 1: Do not re-implement `describe -m … && new`; it is `jj commit`
`jj commit -m "msg"` is defined as exactly "set the description on `@`, then create a new
empty change on top of it" — identical to `jj describe -m "msg" && jj new`. Re-creating it
as a shell chain would be redundant and would drift from upstream behavior (e.g. `jj commit`
also handles the interactive-editor path when `-m` is omitted).

- **Choice**: Provide a fish abbreviation `jc` → `jj commit -m` for ergonomics; do not build
  a describe+new chain.
- **Alternative rejected**: A fish function `jj describe -m $argv && jj new` — more code,
  no benefit, diverges from the built-in.

### Decision 2: Use the community `tug` alias (closest_bookmark), not hardcoded `main`
The literal request was `jj bookmark set main -r @-`. The widely-shared jj idiom
generalizes this so it isn't pinned to one bookmark name:

```toml
[revset-aliases]
'closest_bookmark(to)' = 'heads(::to & bookmarks())'

[aliases]
tug = ["bookmark", "move", "--from", "closest_bookmark(@-)", "--to", "@-"]
```

`tug` finds whatever bookmark is closest behind `@-` and moves it up to `@-`. On a pure
`main` workflow this behaves exactly like `bookmark set main -r @-`, but it also survives
feature branches without editing config.

- **Choice**: `tug` with `closest_bookmark`.
- **Alternative rejected**: Hardcode `tug = ["bookmark", "set", "main", "-r", "@-"]`. Simpler
  and matches the literal ask, but breaks the moment a non-`main` bookmark is in play and is
  less aligned with community docs/snippets.

### Decision 3: `@-` is the target, not `@`
After a commit, `@` is a fresh empty change; the real work sits at `@-`. Both the bookmark
move and the mental model target `@-`.

```
  @        empty working copy (nothing to point a bookmark at)
  │
  @-  ●    ← bookmark should live HERE (last real change)  →  jj git push publishes it
```

## Open question (defer / decide at apply time)
- `jj git push` flags: whether to add `--allow-new` for first-time bookmark creation, and
  whether to set `git.push-default = "current"` (currently commented out in `jj.nix`). Kept
  out of scope here to keep the change additive; can be a follow-up if first-push friction
  shows up.
