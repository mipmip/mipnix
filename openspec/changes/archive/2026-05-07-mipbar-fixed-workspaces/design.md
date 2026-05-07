## Context

Mipbar's `Workspaces.tsx` currently filters workspaces to only show occupied ones (`w.get_clients().length > 0`), sorted by monitor then ID. Hyprland's workspace config binds workspaces 1-7 to the external monitor (`DP-3`) and 8, 9, 0 to the laptop (`eDP-1`).

The workspace indicator uses AGS's reactive `createState` and `For` components. Styling is split between `style.scss` (base styles) and `theme.ts` (dark/light overrides).

## Goals / Non-Goals

**Goals:**
- Always show workspaces 1-9 and 0, regardless of whether they're occupied
- Visual separator between external (1-7) and laptop (8-9, 0) groups
- Laptop workspaces (8, 9, 0) have a distinct accent color
- Both dark and light mode look good
- Occupied workspaces still show app icons

**Non-Goals:**
- Dynamic workspace detection from Hyprland config (hardcode laptop IDs)
- Changing workspace order based on monitor availability

## Decisions

### 1. Fixed workspace list with hardcoded IDs

**Decision**: Always render workspaces `[1, 2, 3, 4, 5, 6, 7, 8, 9, 0]` in this order. For each, look up the Hyprland workspace object (if it exists) to get clients and focused state. If no Hyprland workspace exists for an ID, render an empty placeholder.

### 2. Laptop workspace IDs hardcoded

**Decision**: Workspaces 8, 9, 0 are laptop workspaces. This is hardcoded in the component. A CSS class `laptop` is added to these workspace buttons.

**Rationale**: The workspace-to-monitor binding is defined in Hyprland config and rarely changes. Hardcoding avoids runtime complexity.

### 3. Accent color for laptop workspaces

**Decision**: Laptop workspaces get a subtle tinted background in both modes:
- Dark mode: a cool-toned tint (e.g., `rgba(100, 140, 255, 0.12)`)
- Light mode: a cool-toned tint (e.g., `rgba(60, 100, 220, 0.10)`)

This provides enough distinction without being distracting.

### 4. Light mode workspace background

**Decision**: Add explicit workspace background colors in `theme.ts` for light mode, matching the contrast level of dark mode.

## Risks / Trade-offs

- **[Hardcoded IDs]** If workspace layout changes, the bar code needs updating. → Acceptable: workspace layout is stable config.
- **[Workspace 0]** Hyprland uses ID 0 internally for special purposes sometimes. → Mitigation: filter carefully, only show our explicit workspace 0.
