## 1. drs

- [x] 1.1 Bump the `dirty-repo-scanner` input to 0.4.0 and check `drs --list` and `drs --json`

## 2. Helper and tests

- [x] 2.1 Write `packages/mipbar/widget/dirtyRepoStatus.ts` with `parseDrs`, `totals`, `tooltipText` and `displayName`
- [x] 2.2 Write `dirtyRepoStatus.test.ts` covering empty output, the tooltip text, failure text and the `~` abbreviation
- [x] 2.3 Wire `checks.mipbar-dirty-repos` in `flake.nix` and run all mipbar checks

## 3. Widget

- [x] 3.1 Write `DirtyRepos.tsx`: hourly scan, scan on popover open, in-flight guard, hidden at zero
- [x] 3.2 Popover with name and dim path per repo, sorted by path
- [x] 3.3 Add it to `Bar.tsx` between SshKey and Caffeine; style the popover like AllWindows

## 4. Rollout

- [x] 4.1 Commit, `home-manager switch`, restart mipbar
- [ ] 4.2 User: icon shows the count, tooltip shows the overview
- [ ] 4.3 User: commit in a dirty repo, open the popover, the repo is gone from the list and the count drops
