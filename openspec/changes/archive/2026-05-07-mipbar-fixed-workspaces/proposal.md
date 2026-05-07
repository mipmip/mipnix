## Why

The workspace indicator currently only shows occupied workspaces, making it hard to see the full workspace layout at a glance. There's also no visual distinction between external monitor workspaces and laptop workspaces, and light mode lacks the background differentiation that dark mode has.

Related task: [mipnix-mlf9](../../.beans/mipnix-mlf9--mipbar-show-all-workspaces-from-1-to-9.md)

## What Changes

- Show all fixed workspaces (1-9 and 0) at all times, not just occupied ones
- Order: `1 2 3 4 5 6 7 | 8 9 0` with a visual separator between monitor groups
- Laptop workspaces (8, 9, 0) get a distinct accent color, visible in both dark and light mode
- Light mode workspace background gets proper contrast (matching dark mode behavior)
- Occupied workspaces still show app icons; empty ones show just the number

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `workspace-navigation`: Changing from dynamic (occupied-only) to fixed workspace list with monitor-based color coding

## Impact

- **Files modified**: `packages/mipbar/widget/Workspaces.tsx` (workspace list logic), `packages/mipbar/style.scss` (laptop accent styling), `packages/mipbar/theme.ts` (light/dark mode colors)
