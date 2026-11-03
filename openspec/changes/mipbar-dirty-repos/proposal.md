# Proposal

Bean: [mipnix-gq1b](../../../.beans/mipnix-gq1b--mipbar-showing-number-of-dirty-repos.md)

## Why

Uncommitted work sits in several repos at once and is easy to forget. drs finds those repos, but only when its TUI is opened. A count in mipbar keeps them in sight. drs 0.4.0 added `--list` and `--json`, which give mipbar a stable interface.

## What Changes

- Bump the `dirty-repo-scanner` flake input to 0.4.0.
- A new mipbar icon showing the number of dirty repos, hidden when there are none.
- A tooltip with a status overview: number of repos, totals of staged, unstaged and untracked files, and the time of the last scan.
- A click opens a popover listing the dirty repos. No actions on the rows for now.
- mipbar scans once an hour with `drs --json` and again each time the popover opens.

## Capabilities

### New Capabilities

- `mipbar-dirty-repos`: the dirty repo count, tooltip and popover in mipbar.

### Modified Capabilities

(none)

## Impact

- `flake.lock`: dirty-repo-scanner 0.3.0 to 0.4.0.
- `packages/mipbar/widget/DirtyRepos.tsx` and a pure helper `dirtyRepoStatus.ts` with tests; `Bar.tsx`; `style.scss`.
- `flake.nix`: a `mipbar-dirty-repos` check.
- Uses the drs config already managed in `modules/USERS/pim/programs/dirty-repo-scanner/`.
- Rollout: `rme up_home`.
