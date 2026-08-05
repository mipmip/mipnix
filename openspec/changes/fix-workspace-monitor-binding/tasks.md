> ⚠️ ROLLED BACK 2026-07-03: the implemented reconcile-on-workspace-event
> approach made the session unstable (likely an event feedback loop despite the
> debounce, and/or churn from moving 1–7 on every focus). Both touched files were
> reverted to their pre-change state (commit 565f6f32): DP-3 pins restored in
> workspaces.conf, original monitor-only listener restored in the rehome script.
> The tasks below are LEFT AS-WAS for the record; do NOT treat them as applied.
> The underlying bug (workspaces landing on the laptop) is still unresolved and
> needs a different approach — investigate later, calmly, not on a Friday.
> Candidates for the retry: don't reconcile the whole 1–7 set on every event
> (only the focused workspace); or avoid the runtime move entirely and fix it at
> the rule level.

## 1. Static config: remove the connector lie

- [x] 1.1 In `modules/USERS/pim/programs/hyprland/hypr/workspaces.conf`, remove
      `monitor:DP-3` from workspaces 1–7 (change `workspace=1,monitor:DP-3,default:true`
      → `workspace=1,default:true`; drop the `monitor:DP-3` from 2–7). Keep the
      `monitor:eDP-1` pins on workspaces 8, 9, 0.
- [ ] 1.2 Confirm via `hyprctl workspacerules` (after rebuild + reload) that
      workspaces 1–7 no longer carry a `DP-3` (or any connector) rule, while 8/9/0
      keep `eDP-1`.

## 2. Reconciliation: fire on workspace events, with a loop guard

- [x] 2.1 In `modules/USERS/pim/programs/hyprland/scripts/workspace-monitor-rehome`,
      extend the socket2 `case` to also match workspace focus/create and
      focused-monitor events (`workspace`/`workspacev2`/`createworkspace*`/`focusedmon*`)
      and call `reconcile` — verify the exact event names against live socket2 output.
- [x] 2.2 Add a debounce / self-trigger guard so `moveworkspacetomonitor` dispatched
      by `reconcile` cannot re-trigger `reconcile` into a loop.
- [x] 2.3 Tune the settle delay for workspace events (the existing `sleep 0.3` is for
      monitor settle; use a shorter/no delay for workspace events to minimize flicker).
- [x] 2.4 Correct the script header comment (the file is an immutable repo-owned
      symlink; nwg-displays does not rewrite it at runtime).

## 3. Verify

- [x] 3.1 With external connected: switch to each of workspaces 1–7 (no hotplug) and
      confirm each lands on the external monitor, not `eDP-1`.
      → Reconcile logic verified live: ws1 was stranded on eDP-1 (the bug); one
      reconcile pass moved 1–7 to DP-2 (external), 8/9/0 to eDP-1. Full end-to-end
      (DP-3 rules gone) needs the rebuild — the running session still has the old
      baked-in workspace rules until `up_home` + reload.
- [x] 3.2 Confirm workspaces 8/9/0 stay on `eDP-1`.
      → Verified in the same live pass (ws9 on eDP-1; 8/0 keep the eDP-1 pin).
- [ ] 3.3 Hotplug test: unplug/replug external; confirm 1–7 follow and fall back
      correctly (unchanged behavior).
- [ ] 3.4 Watch for an event loop: monitor `hyprctl` / CPU during rapid workspace
      switching; confirm no runaway `moveworkspacetomonitor` storm.
- [ ] 3.5 Confirm no visible/persistent flicker regression on workspace switch.
