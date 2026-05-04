## Context

The bar uses GTK4's theme variables (`@theme_fg_color`, `@theme_bg_color`) for base colors. However:
1. Interactive states (hover, active, focused) use hardcoded `rgba(255, 255, 255, ...)` — white overlays that assume a dark background.
2. AGS compiles SCSS once at startup — theme color variables are resolved at that point and don't update when the system color scheme changes at runtime.

## Goals / Non-Goals

**Goals:**
- All interactive states work correctly in both light and dark GTK themes
- Bar automatically follows system color scheme changes at runtime

**Non-Goals:**
- Adding a toggle/switch in the bar itself
- Supporting custom color schemes beyond what GTK provides
- Changing the bar's visual design

## Decisions

### Use `#{"alpha(@theme_fg_color, ...)"}`  for interactive overlays

Use SCSS string interpolation to pass `alpha(@theme_fg_color, 0.1)` through to GTK CSS verbatim.

**Why**: SCSS intercepts `alpha()` as a Sass function, so we must escape it. The `#{"..."}` syntax passes the string through unmodified to GTK CSS, which resolves `@theme_fg_color` at runtime.

### Use `@error_color` for screenshare indicator

Replace `#ff4444` with `#{"@error_color"}`.

**Why**: Theme-provided error colors are designed to be visible against both light and dark backgrounds.

### Re-apply CSS on color scheme change

Watch `Gtk.Settings.get_default()` for `notify::gtk-application-prefer-dark-theme` or the `color-scheme` property via `GtkSettings`. When the scheme changes, re-apply the stylesheet via `app.apply_css()`.

**Why**: AGS compiles SCSS once at startup. Without re-applying, the GTK CSS named colors (`@theme_fg_color` etc.) resolve to their initial values and never update. Re-applying forces GTK to re-resolve the named colors against the new theme.

**Alternative considered**: Restarting AGS on scheme change. Rejected because it causes a visible flicker and is a worse UX.

## Risks / Trade-offs

[Risk] `alpha()` must be escaped from SCSS with `#{"..."}` interpolation to avoid SCSS compile errors → Already handled.

[Risk] The exact GtkSettings signal for color scheme changes may vary — need to verify which property/signal fires when the Hyprland keybind toggles dark/light mode.
