# Window Title

**Bean**: [mipbar-ufrv](../../../.beans/mipbar-ufrv--in-the-middle-application-title-of-current-app.md)
**Status**: proposed

## Why

The center section of the bar is empty. Showing the focused window's title gives context about the current app, matching ashell's WindowTitle module.

## What Changes

- Create a WindowTitle widget that shows the focused client's icon and title
- Place it in the center section of the bar
- Title truncates with ellipsis when too long
- Hidden when no window is focused

## Capabilities

### New Capabilities

- `window-title` — Display the focused window's icon and title in the center of the bar

### Modified Capabilities

None.

## Impact

- New `widget/WindowTitle.tsx`
- `widget/Bar.tsx` — replace empty center box with WindowTitle
- `style.scss` — title truncation and styling

## Assumptions

- `AstalHyprland` already included in the project
- `focusedClient` property is reactive and updates on window switch and title change
- `lookupIcon()` from Workspaces.tsx can be extracted or duplicated for icon resolution

## Non-goals

- Clicking the title to do anything (just display)
- Showing multiple window titles
- Showing workspace name when no window is focused
