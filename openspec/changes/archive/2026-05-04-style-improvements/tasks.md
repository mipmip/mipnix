## 1. Bar background transparency

- [x] 1.1 Change centerbox background from solid `$bg-color` to `alpha(@theme_bg_color, 0.9)`

## 2. Strip button backgrounds

- [x] 2.1 Set `background: transparent` on all `button` and `menubutton` elements within the bar
- [x] 2.2 Ensure hover and active states still show `alpha(@theme_fg_color, 0.1/0.2)` backgrounds

## 3. Workspace group background

- [x] 3.1 Add `alpha(@theme_fg_color, 0.06)` background with border-radius to `.Workspaces` container

## 4. Compact sizing

- [x] 4.1 Reduce WorkspaceButton `min-height` from 28px to 22px and tighten padding
- [x] 4.2 Reduce global button margin from 2px to 1px
- [x] 4.3 Reduce focused workspace `border-radius` from 14px to 8px

## 5. Systray spacing

- [x] 5.1 Reduce `.TrayItem` padding from `2px 4px` to `1px 2px` and margin from `0 1px` to `0`
