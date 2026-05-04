## Context

The bar is styled via `style.scss` using SCSS with GTK4 Adwaita theme color references. Currently, all interactive elements (buttons, menubuttons, tray items) inherit the GTK theme's default button background, which creates visible "cards" that contrast against the bar background. The bar uses a solid `$bg-color` background with no transparency.

## Goals / Non-Goals

**Goals:**
- Achieve a cleaner, more minimal bar aesthetic
- Remove unnecessary visual weight from non-highlighted elements
- Create a subtle visual grouping for workspaces
- Reduce overall bar height

**Non-Goals:**
- Changing widget behavior or layout order
- Adding animations or transitions
- Theming beyond the bar (no global GTK theme changes)

## Decisions

### Strip button backgrounds globally within the bar

Set `background: transparent` on all `button` and `menubutton` elements within the bar. Only restore backgrounds for hover, active, and focused states.

**Why**: The default GTK button chrome creates visual noise. Most bar elements (launcher, clock, tray) should blend into the bar background. Interaction feedback (hover/active) still provides discoverability.

### Use alpha on theme_bg_color for bar transparency

Set centerbox background to `alpha(@theme_bg_color, 0.9)` instead of solid `$bg-color`.

**Why**: A slight wallpaper bleed-through gives the bar a lighter feel. Starting at 0.9 keeps it subtle — readable over any wallpaper but not heavy.

### Add grouped background to Workspaces container

Apply a subtle `alpha(@theme_fg_color, 0.06)` background with border-radius to the `.Workspaces` box.

**Why**: With button backgrounds removed, workspace buttons need a visual container to remain perceived as a group. A very faint fg-alpha background creates this grouping without adding weight.

### Reduce focused workspace border-radius to 8px

Change from `border-radius: 14px` (pill) to `8px` (matching the general button radius).

**Why**: The pill shape is too prominent for the minimal direction. 8px is rounded enough to feel distinct but doesn't dominate.

### Reduce bar height via padding and min-height

Reduce WorkspaceButton `min-height` from 28px to 22px, tighten padding across buttons, and reduce global button margin.

**Why**: The bar feels tall relative to its content. Smaller touch targets are acceptable for a desktop bar (not mobile).

### Tighten systray spacing

Reduce `.TrayItem` padding from `2px 4px` to `1px 2px` and margin from `0 1px` to `0`.

**Why**: Systray icons are small and don't need generous padding. Tighter spacing makes the tray feel more cohesive.

## Risks / Trade-offs

[Risk] Transparent button backgrounds may make some elements hard to discover as clickable → Mitigation: Hover states still reveal interactivity. The bar is a familiar UI pattern where users expect clickability.

[Risk] Bar transparency at 0.9 may not be visible enough to notice → Mitigation: This is intentional — start subtle, can be adjusted later.

[Risk] Reduced height may clip icons or text on some GTK themes → Mitigation: Test with the active theme; min-height values are conservative.
