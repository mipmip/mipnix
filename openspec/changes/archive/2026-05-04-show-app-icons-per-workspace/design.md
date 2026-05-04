## Context

The bar's workspace navigation (in `widget/Workspaces.tsx`) currently shows occupied workspaces as numbered buttons grouped by monitor. The `astal-hyprland` library provides reactive GObject bindings with access to workspace clients and their properties (class, title). The bar already uses `<image iconName={...} />` for status icons (Battery, Wifi), establishing a pattern for themed icon rendering.

## Goals / Non-Goals

**Goals:**
- Display desktop-themed application icons inside each workspace button
- Show window titles on hover via tooltip
- React to all client lifecycle events (open, close, move) so icons are always current

**Non-Goals:**
- Click-to-focus individual windows from the workspace button (taskbar behavior)
- Custom icon mappings for edge-case app classes (can be added later)
- Limiting/truncating the icon list for workspaces with many windows

## Decisions

### Use Hyprland client-level signals for reactivity

Listen to `client-added`, `client-removed`, and `client-moved` signals on the Hyprland singleton. Combine these with the existing `workspaces` binding to trigger a full recompute of the workspace items list.

**Why**: The current `createBinding(hyprland, "workspaces")` only fires when workspaces are added/removed. It does not fire when a window opens in an existing workspace. The three client signals cover every case where a workspace's icon list could change.

**Approach**: Use `createSignal` to hold a revision counter. Increment it from both the workspace binding and the three client signal handlers. Derive the workspace items list reactively from this counter.

**Alternative considered**: Polling `get_clients()` on an interval — rejected because it's wasteful and introduces latency.

### Use Client.class as GTK icon name

Pass `client.class` (e.g. `"firefox"`, `"kitty"`, `"org.gnome.Nautilus"`) directly to `<image iconName={...} />`. GTK's icon theme lookup resolves this to the correct themed icon.

**Why**: Most applications set their WM class to match their desktop file name, which matches their icon theme entry. This works out of the box for the vast majority of apps.

**Fallback**: Use `"application-x-executable"` as the fallback icon when a class doesn't resolve.

**Alternative considered**: Nerd Font glyphs with a mapping table — rejected because desktop icons are richer, consistent with the existing status icon pattern, and require no maintenance.

### Per-icon tooltip

Set `tooltipText` on each individual `<image>` icon rather than on the workspace button. Each icon shows its own window's title on hover.

**Why**: When multiple windows of the same app are open, each icon needs to be distinguishable. Per-icon tooltips let the user identify which Firefox window is which, for example.

**Alternative considered**: Single tooltip on the workspace button with all titles joined by newlines — rejected because it doesn't let the user associate titles with specific icons.

### Inline icons within workspace button

Render icons inside the existing workspace button alongside the workspace ID label. The button's child becomes a `<box>` containing `[label] [icon] [icon] ...`.

**Why**: Keeps the workspace ID visible for orientation. Icons provide at-a-glance app identification without replacing the familiar numeric indicator.

### One icon per window (no deduplication)

Show one icon for every window in the workspace, even if multiple windows share the same app class. Each icon has its own tooltip with that window's title.

**Why**: The user wants to see and distinguish individual windows. With per-icon tooltips, duplicate icons are meaningful — hovering reveals which specific window each represents.

## Risks / Trade-offs

[Risk] Some apps have WM classes that don't match icon theme names (e.g. `electron`, `steam_app_*`) → Mitigation: Fallback icon covers this. A mapping table can be added as a follow-up if needed.

[Risk] Workspaces with many different apps could make buttons very wide → Mitigation: Accept for now. CSS can constrain max-width with overflow hidden as a follow-up.

[Risk] Icon theme may not be loaded or may lack entries → Mitigation: GTK falls back gracefully; `application-x-executable` is a standard icon in all themes.
