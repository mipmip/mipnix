## Why

`MOD+0` does not switch to a workspace. Nothing happens.

**Root cause: Hyprland has no workspace id 0.** Workspace ids start at 1, so
`dispatch workspace 0` is not addressable and silently does nothing. Verified live
on doornappel (Hyprland 0.55.4):

```
~/.config/hypr/workspaces.conf:12   workspace=0,monitor:eDP-1     ← declared
$ hyprctl workspaces                 id 10, id 8, id 1             ← id 0 absent
```

The declaration has been loaded since session start and workspace 0 has still never
materialized. Workspace **10** does exist, holds a window, and is the workspace the
user actually reaches by other means (e.g. the 3-finger `gesture = 3, horizontal,
workspace` in `inputs.conf:22` walking past 9).

**How it regressed.** The archived change
`2026-07-02-fix-hyprland-monitor-topology-and-ws0-icons` correctly diagnosed a
three-way identity mismatch — `MOD+0` dispatched `workspace 10`, `workspaces.conf`
declared `workspace=0`, and the mipbar "0" button queried id 0 — but resolved it by
standardizing on **0**, the only one of the three values that cannot exist:

> **Bug 2 — unify workspace 0.** Change `binds.conf` so `MOD+0` dispatches
> `workspace 0` and `MOD+SHIFT+0` dispatches `movetoworkspace 0` (instead of `10`)

Before that change `MOD+0` worked and only the bar was wrong. After it, navigation
broke too. The fix must go the other way: standardize on **id 10, labelled "0"**.

**A second, hidden symptom.** `workspace-monitor-rehome` carries `LAPTOP_WS="8 9 0"`
and dispatches `moveworkspacetomonitor "0 eDP-1"` behind `>/dev/null 2>&1`, so the
failure is invisible. The workspace that actually exists is never bound, and live
state shows it stranded on the external monitor:

```
id 10   monitor HDMI-A-1   ← should be on eDP-1 per laptop-workspaces-stay-on-panel
```

This also corrects a wrong conclusion recorded in the active (rolled-back) change
`fix-workspace-monitor-binding`, whose Out of Scope section reads:

> The stray runtime `workspace 10` … appears to be runtime cruft, not part of this fix.

It is not cruft. It is the only real workspace of the three candidates; the config's
`0` is the fiction.

Found via `/opsx:explore mipnix-zsgz`.

## What Changes

- **Retarget the keybinds.** `MOD+0` → `workspace 10`, `MOD+SHIFT+0` →
  `movetoworkspace 10`, reversing the 2026-07-02 change.
- **Fix the static declaration.** `workspaces.conf` declares `workspace=10,monitor:eDP-1`
  instead of the inert `workspace=0`.
- **Fix the reconciliation set.** `workspace-monitor-rehome` uses `LAPTOP_WS="8 9 10"`
  so the laptop workspace is actually bound to `eDP-1`.
- **Decouple label from id in mipbar.** `Workspaces.tsx` currently uses one number as
  both the workspace id and the button label (`WORKSPACE_IDS = [1..9, 0]`). Split
  them so the tenth button carries `id: 10` and `label: "0"` — the id is used for
  lookup and dispatch, the label only for display.
- **Reverse the spec.** `hyprland-workspace-zero` currently mandates the broken
  behavior in as many words ("SHALL switch to workspace id 0 (not workspace id 10)").
  Its premise — that id 0 can be first-class — is unachievable on Hyprland and must
  be restated in terms of id 10 presented as "0".

## Capabilities

### Modified Capabilities

- `hyprland-workspace-zero`: invert the identity decision. The workspace labelled
  "0" SHALL be workspace **id 10** consistently across keybind, static declaration,
  monitor reconciliation, and the mipbar button. Adds a requirement that the bar
  distinguishes display label from workspace id, so the two cannot drift again.
- `hyprland-monitor-topology`: `laptop-workspaces-stay-on-panel` names workspaces
  "8, 9, and 0"; restate as 8, 9, and the workspace labelled 0 (id 10) so the
  requirement is verifiable against `hyprctl workspaces` rather than being
  vacuously true for a workspace that never exists.

## Impact

- `modules/USERS/pim/programs/hyprland/hypr/binds.conf`: lines 68 and 80.
- `modules/USERS/pim/programs/hyprland/hypr/workspaces.conf`: line 12.
- `modules/USERS/pim/programs/hyprland/scripts/workspace-monitor-rehome`: `LAPTOP_WS`.
- `packages/mipbar/widget/Workspaces.tsx`: `WORKSPACE_IDS` and the `WorkspaceItem`
  shape (add a `label` distinct from `id`); `LAPTOP_IDS` must move to id 10 too.

## Interaction with `fix-workspace-monitor-binding`

That change is active but **rolled back** (see the banner in its `tasks.md`). It
touches two of the same files (`workspaces.conf`, `workspace-monitor-rehome`) but
only the workspace **1–7** connector pins and the listener's event triggers. This
change touches only the workspace-0/10 identity. The edits do not overlap line-wise,
and this one does not depend on that one being resolved first — but whoever retries
`fix-workspace-monitor-binding` should rebase on this, since `LAPTOP_WS` will have
changed.

## Out of Scope

- The general problem that mipbar can only ever render an allowlist of workspace ids,
  so a window on any unexpected workspace (11, named, other special) is invisible.
  This change fixes one specific id; the safety net is `add-all-windows-picker`
  (bean `mipnix-zsgz`).
- Retrying the rolled-back `fix-workspace-monitor-binding` reconciliation approach.
