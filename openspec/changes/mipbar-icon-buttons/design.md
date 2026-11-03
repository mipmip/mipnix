# Design

## Context

The system monitor is a bare `menubutton` and gets the bar's button rule (`window.Bar button, menubutton > button`: transparent, radius 8px, hover `alpha(fg, 0.1)`) plus the theme's button padding. The other icons carry `StatusIcon`, which sets `padding: 0 4px; margin: 0 2px` on the outer widget and `button { all: unset; padding: 0 }` inside. For a `box` with a `button` (keep-awake, camera, screen share) that removes padding and hover. For a `menubutton` the padding sits outside the inner button, so the hover area hugs the glyph.

Red lives in `theme.ts` as `.StatusIcon.Camera` / `.StatusIcon.Screenshare` colour, `#ff4444` dark and `#cc0000` light. Keep-awake on is amber in `style.scss`.

## Goals / Non-Goals

**Goals:** one presentation for every bar icon; new icons right by default; keep-awake red when on.

**Non-Goals:** a pill or background for camera and screen share; changes to popovers; the tray, the clock and the quick settings group.

## Decisions

### One class on the button, padding inside

Each icon's clickable widget (`menubutton` or `button`) gets the class `BarIcon`. The rule styles its button node:

```scss
.BarIcon > button, button.BarIcon {
  padding: <same as the system monitor>;
  border-radius: 8px;
  min-width / min-height: equal for all
}
```

The hover comes from the existing bar button rule, which then reaches every icon. `.StatusIcon button { all: unset }` and the outer `padding` on `.StatusIcon` go. `StatusIcon` stays as the hook for per-widget colours. The exact padding is read off the system monitor's rendered button (GTK inspector) and written down explicitly, so it no longer depends on the theme.

The system monitor gets `BarIcon` too, so it is the same rule and not the reference by accident.

### Test

A Bun test reads `Bar.tsx` for the widgets in the end box (tray, clock and QuickSettings excluded), opens each widget file and checks that its root clickable carries `BarIcon`. It also checks that `style.scss` has no `all: unset` on a bar icon button. This makes the spec's "new icon" scenario fail loudly instead of drifting.

### Keep-awake colour

The amber rule in `style.scss` goes. `theme.ts` gets `.StatusIcon.Caffeine.on` in the same block as camera and screen share, for both themes, so the reds stay in one place. Off stays `#6e738d`.

### Coffee glyph nudge

`margin-top: 1px` on the keep-awake label. It is an optical correction for this glyph only.

### Indicator size

Camera and screen share both use `-gtk-icon-size: 16px`.

## Risks / Trade-offs

- [The bar may grow wider with nine padded icons] → the padding matches the system monitor, which already fits; check on the laptop screen.
- [A Nerd Font glyph and a symbolic icon have different visual weight] → equal button size keeps the rhythm; glyph sizes are left as they are.
