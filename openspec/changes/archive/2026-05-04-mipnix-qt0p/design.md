## Context

Mipbar is a top-anchored status bar styled with SCSS. The centerbox already uses `alpha(@theme_fg_color, ...)` throughout for hover/active states and `alpha(@theme_bg_color, 0.9)` for its background. There is no bottom border or separator.

## Goals / Non-Goals

**Goals:**
- Add a subtle bottom border that defines the bar's lower edge
- Maintain consistency with existing alpha-based styling approach

**Non-Goals:**
- Shadows, gradients, or soft separators
- Per-theme hardcoded colors

## Decisions

**Use `border-bottom` on `window.Bar > centerbox`**
A single CSS property addition. Uses `alpha(@theme_fg_color, 0.08)` — the same pattern used for button hover states but at lower opacity. This automatically adapts to light/dark themes since `@theme_fg_color` flips with the theme.

Alternative considered: `box-shadow` — rejected because the user explicitly wants a hard line, not soft depth.

## Risks / Trade-offs

- The 1px border may render slightly differently across monitor scales (fractional scaling). At 0.08 opacity this is unlikely to be noticeable.
