## Context

`hyprland-monitor-topology` places workspaces 1–7 on the external monitor and
8/9/0 on the laptop panel `eDP-1`, reconciled at runtime by
`modules/USERS/pim/programs/hyprland/scripts/workspace-monitor-rehome`. The script
picks the external monitor as "first monitor whose name is not `eDP-1`" and
dispatches `moveworkspacetomonitor`.

Two conflicting authorities were found during exploration:

```
  workspaces.conf rules              rehome script
  ─────────────────────              ──────────────
  target: DP-3 (hardcoded)           target: "not eDP-1" (correct, e.g. DP-2)
  fires:  every workspace            fires:  monitor add/remove + startup
          focus/create                       (NOT workspace events)

  workspace focus (no hotplug) ─▶ DP-3 rule fires ─▶ DP-3 absent ─▶ eDP-1  ✗
  monitor replug               ─▶ script fires    ─▶ DP-2               ✓
```

Confirmed live: `hyprctl workspacerules` showed `ws 1–7 → DP-3` while only
`eDP-1` + `DP-2` were connected; workspaces landed on `eDP-1` on focus.

`workspaces.conf` is a home-manager **immutable Nix-store symlink** built from the
repo — so the earlier assumption that nwg-displays rewrites it at runtime is false;
the `DP-3` value is a frozen repo mistake sourced on every start.

## Goals / Non-Goals

**Goals:**
- Workspaces 1–7 reliably land on the connected external monitor, including on
  plain workspace focus/create (no monitor event required).
- Remove the static connector pin that cannot be correct for a variable connector.
- Keep a single, correctly-triggered owner of the 1–7 binding.

**Non-Goals:**
- A manual "move workspace to other monitor" shortcut (bean `mipnix-gfz4` — out of
  scope; likely unnecessary once auto-binding works).
- Changing monitor geometry ownership (nwg-displays / `monitors.conf`).
- The stray runtime `workspace 10` (unrelated cruft).

## Decisions

### Remove `monitor:DP-3` from workspaces 1–7; keep everything else

`workspaces.conf` becomes:

```
workspace=1,default:true      # was: workspace=1,monitor:DP-3,default:true
workspace=2 .. workspace=7    # no monitor: rule
workspace=8,monitor:eDP-1,default:true   # kept — eDP-1 is stable
workspace=9,monitor:eDP-1                 # kept
workspace=0,monitor:eDP-1                 # kept
```

`default:true` is independent of the monitor pin, so ws1 stays the default
workspace. The eDP-1 pins are correct (laptop panel is always `eDP-1`).

### Reconcile on workspace events, not only monitor events

Extend the socket2 case in `workspace-monitor-rehome` to also match workspace
focus/create (and focused-monitor change) events, then reconcile. Without a static
rule, a fresh 1–7 workspace binds to the *focused* monitor on first focus (possibly
the laptop); the workspace-event reconcile immediately pulls it to the external
monitor.

### Guard against self-triggered loops

`moveworkspacetomonitor` can emit workspace events, which would re-enter the
listener. Guard with a short debounce and/or an "in-reconcile" flag so a reconcile
does not recursively trigger itself. The existing `sleep 0.3` settle is tuned for
monitor events; workspace-event reconciles may use a shorter/no settle to minimize
the visible flicker — to be tuned during implementation.

## Risks / Trade-offs

- **[Trade-off] brief flicker.** A 1–7 workspace may appear on the focused monitor
  for a beat before being moved to the external one. Accepted — a static pin is the
  only alternative and it cannot name a variable connector. The workspace-event
  trigger minimizes the window vs. the current monitor-only trigger.
- **[Risk] event loop.** Mitigated by the debounce/guard (see Decisions). Primary
  implementation risk; verify no runaway `moveworkspacetomonitor` storm.
- **[Risk] event-name drift.** Hyprland socket2 event names (`workspace>>`,
  `createworkspace>>`, `focusedmon>>`, and their `v2` variants) must be matched
  correctly; verify against the running compositor's actual emissions.

## Alternatives Considered

- **Keep the DP-3 rule, only add workspace-event reconcile** — rejected: leaves two
  disagreeing owners; the script would fight the rule on every focus (flicker,
  race). Removing the lie is cleaner.
- **Generate workspaces.conf with the correct connector at build time** — impossible:
  the external connector is only known at runtime (varies DP-2/DP-3). This is
  precisely why the runtime script exists.
- **A manual shortcut instead of fixing auto-binding** (the original bean framing)
  — rejected as a band-aid: the stale rule would re-strand the workspace on the
  next focus.
