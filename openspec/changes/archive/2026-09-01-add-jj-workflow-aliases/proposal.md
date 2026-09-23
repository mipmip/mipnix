## Why

Working in jj (jujutsu) repos, two operations are performed constantly but require
multiple commands each:

1. **Finish a change and start the next** — `jj describe -m "msg" && jj new`. This is
   the everyday "commit and move on" motion. jj already ships this as the built-in
   `jj commit -m "msg"` (describe `@`, then create a fresh empty change on top), but
   the muscle memory of typing the two commands separately persists.
2. **Publish work** — advance the `main` bookmark to the last real change and push it:
   `jj bookmark set main -r @- && jj git push`. After a commit, `@` is empty, so the
   work lives at `@-`; the bookmark must be moved there before pushing.

Neither is discoverable and both are error-prone to type. jj's native `[aliases]`
mechanism maps one name to one subcommand and cannot chain with `&&`, so the multi-step
"publish" motion has no home today. This change adds ergonomic shortcuts in the right
places (jj config for single-subcommand aliases, fish abbreviations for chained motions).

## What Changes

- Add a jj `tug` alias (community-standard) that moves the closest bookmark behind the
  working copy up to `@-`, plus the `closest_bookmark` revset alias it depends on. This
  generalizes the hardcoded `bookmark set main -r @-` so it works for any bookmark.
- Add a fish abbreviation `jp` (jj publish) expanding to `jj tug && jj git push`.
- Add a fish abbreviation `jc` (jj commit) expanding to `jj commit -m`, capturing the
  describe+new motion via the existing built-in rather than a hand-rolled chain.
- Document that `jj describe -m … && jj new` is intentionally NOT re-implemented because
  `jj commit` already is it.

## Capabilities

### New Capabilities
- `jj-workflow-aliases`: jj config aliases and fish abbreviations for the two core jj
  motions — finish-and-continue (`jc` → `jj commit`) and publish (`jp` → `jj tug && jj git push`).

### Modified Capabilities
- (none)

## Impact

- **Code**:
  - `modules/USERS/pim/programs/jj.nix` — add `aliases` and `revset-aliases` to
    `programs.jujutsu.settings`.
  - `modules/USERS/pim/programs/fish/default.nix` — add `jp` and `jc` abbreviations.
- **Dependencies**: `jj` (already installed via `programs.jujutsu`).
- **Systems**: jj CLI and fish shell in all terminals for user `pim`.
- **Risk**: Low, additive only. `tug` operates on `@-`; if no bookmark exists behind the
  working copy the alias is a no-op error, not destructive.
