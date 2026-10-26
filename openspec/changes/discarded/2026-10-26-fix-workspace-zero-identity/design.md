## Context

Six sites encode "the tenth workspace". Five say `0`; Hyprland only understands `10`.

```
site                                          says   Hyprland sees
────────────────────────────────────────────  ─────  ─────────────────────────
binds.conf:68   workspace, 0                  0      inert — nothing happens
binds.conf:80   movetoworkspace, 0            0      inert
workspaces.conf:12  workspace=0,monitor:eDP-1 0      rule never matches a real ws
workspace-monitor-rehome:24  LAPTOP_WS="8 9 0" 0     dispatch fails, hidden by 2>&1
Workspaces.tsx:24  WORKSPACE_IDS [1..9, 0]    0      lookup misses; button inert
─────────────────────────────────────────────────────────────────────────────
reality:        hyprctl workspaces            10     exists, holds windows
```

The 2026-07-02 change made four of these agree on `0`, which produced a
self-consistent configuration describing a workspace that cannot exist. Consistency
was achieved; correctness was lost. The lesson worth encoding is that the shared
value must be one Hyprland can address — hence the new
`no configuration names workspace id 0` scenario, which is checkable by grep.

## Goals / Non-Goals

**Goals**
- `MOD+0` and `MOD+SHIFT+0` work.
- The workspace labelled "0" is bound to `eDP-1` like the other laptop workspaces.
- mipbar's "0" button previews and switches to the workspace the keybind reaches.
- The configuration cannot silently name an unaddressable workspace again.

**Non-Goals**
- Making the bar resilient to *arbitrary* unexpected workspace ids (11, named,
  special). That is the separate `add-all-windows-picker` safety net.
- Re-attempting the rolled-back `fix-workspace-monitor-binding` reconciliation.

## Decisions

### Standardize on id 10, labelled "0"

The alternative — keep `0` everywhere and teach Hyprland about it — is not available;
ids are 1-based in the compositor. The only other option is to relabel the button
"10", widening the bar and breaking the `MOD+<digit>` mnemonic for a keyboard that
has one `0` key. Rejected: the label is the part users touch, the id is the part the
compositor touches, and they simply are not the same value here.

### Separate label from id in mipbar rather than swapping a constant

`Workspaces.tsx` uses a single number for lookup, dispatch, CSS grouping, and display
text. Swapping `0`→`10` in `WORKSPACE_IDS` fixes lookup and dispatch but renders a
button reading "10". The `WorkspaceItem` shape gains a `label`, and only the render
path uses it:

```
WORKSPACES = [ {id: 1, label: "1"}, …, {id: 9, label: "9"}, {id: 10, label: "0"} ]
                                       ▲                      ▲
                             lookup + dispatch          display only
```

`LAPTOP_IDS` becomes `{8, 9, 10}` — it keys off ids, so it must move too, or the
laptop accent and the group separator land on the wrong buttons.

### Fix `workspaces.conf` even though the rehome script also binds it

The static declaration and the runtime reconciliation both target this workspace.
Leaving `workspace=0` in place would be harmless (it matches nothing) but keeps a
lie in the repo and would fail the new grep-checkable scenario. Both are corrected.

Note this file is an immutable Nix-store symlink built from the repo — the
`fix-workspace-monitor-binding` change established that nwg-displays cannot rewrite
it at runtime, contrary to the older comment in the rehome script header.

## Risks / Trade-offs

- **The existing window on id 10 is currently on the external monitor.** After the
  rehome fix it will be pulled to `eDP-1` on the next reconcile. That is the
  specified behavior, but it will visibly move a window the first time it runs.
- **Reversing a shipped spec.** `hyprland-workspace-zero`'s original scenarios are
  kept by title (the validator requires it) with inverted content, so the archive
  history shows the reversal rather than hiding it.
- **`LAPTOP_WS` collides with the rolled-back change.** Whoever retries
  `fix-workspace-monitor-binding` must rebase; called out in that proposal's terms in
  this one's *Interaction* section.

## Verification approach

Every claim in the spec deltas is checkable without a GUI:

| Scenario | Check |
|-----------------------------------|-------------------------------------------------|
| switching to workspace 0 | press `MOD+0`, `hyprctl activeworkspace` → id 10 |
| the declared workspace exists | `hyprctl workspaces` reports id 10 |
| no configuration names id 0 | grep the four config sites for a bare `0` id |
| reconciliation targets addressable | run `reconcile`, `hyprctl workspaces` → 10 on eDP-1 |
| clicking dispatches the id | click the "0" button, `hyprctl activeworkspace` |

The pre-fix state is already recorded in the proposal (id 10 on `HDMI-A-1`), so the
rehome fix has a concrete before/after.
