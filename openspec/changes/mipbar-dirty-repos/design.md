# Design

## Context

drs 0.4.0 prints dirty repositories as JSON:

```json
[{ "path": "/home/pim/mipnix", "vcs": "git",
   "status": { "staged": 0, "unstaged": 3, "untracked": 1 } }]
```

A scan of the current config takes about 1 s. Walk errors go to stderr. mipbar widgets poll with `interval` from `ags/time` and run commands with `execAsync`; the camera widget keeps its parsing in a pure module (`cameraUsers.ts`) with a node test wired as a flake check.

## Goals / Non-Goals

**Goals:** a count, a status tooltip and a read-only list; cheap enough to run hourly.

**Non-Goals:** opening a repo from the popover, committing from the bar, a separate scan schedule per repo.

## Decisions

### Pure helper plus widget

`widget/dirtyRepos.ts` holds `parseDrs(json)`, `totals(repos)`, `tooltipText(state)` and `displayName(path, home)`. It imports nothing from GTK or AGS, so `dirtyRepos.test.ts` runs headless as `checks.mipbar-dirty-repos`, the same as `mipbar-camera`.

`widget/DirtyRepos.tsx` holds the state (`repos`, `scannedAt`, `failed`), runs `execAsync(["drs", "--json"])`, and renders:

```
<menubutton class="StatusIcon BarIcon DirtyRepos" visible={count > 0}>
  <box> glyph 󰊢  +  count label </box>
  <popover> rows: name (bold) / ~/path (dim) </popover>
</menubutton>
```

The `BarIcon` class gives the shared padding and hover, and the `mipbar-icon-buttons` check requires it.

### Schedule

`interval(3600_000, scan)` fires once at start and then hourly. The popover's `notify::visible` triggers `scan()` when it becomes visible, the same trigger Displays uses. A boolean `inFlight` guard skips a scan while one runs.

### drs on PATH

mipbar runs in the Hyprland session, where `~/.nix-profile/bin` is on PATH and drs is installed by `modules/USERS/pim/programs/dirty-repo-scanner`. The widget calls `drs` by name, so it uses the managed config. If drs is missing, the scan fails and the tooltip says so.

### Hidden at zero

Like the camera and screen share indicators, the icon only shows when there is something to act on.

### Placement

Between `SshKey` and `Caffeine` in the end box.

## Risks / Trade-offs

- [The count can be up to an hour old] → opening the popover rescans; the tooltip shows the scan time.
- [A full scan briefly uses one core for about a second] → once an hour is negligible.
