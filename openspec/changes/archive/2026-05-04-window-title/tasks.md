# Tasks: Window Title

## 1. Extract Icon Lookup

- [x] 1.1 Move `lookupIcon()` and `iconCache` from `widget/Workspaces.tsx` to a shared `widget/utils.ts`
- [x] 1.2 Update `widget/Workspaces.tsx` to import from `widget/utils.ts`

## 2. Create WindowTitle Widget

- [x] 2.1 Create `widget/WindowTitle.tsx` importing `AstalHyprland`
- [x] 2.2 Bind to `focusedClient` reactively
- [x] 2.3 Show app icon using `lookupIcon(client.class)`
- [x] 2.4 Show window title with ellipsize for truncation
- [x] 2.5 Hide widget when no client is focused

## 3. Integrate into Bar

- [x] 3.1 Import WindowTitle in `widget/Bar.tsx`
- [x] 3.2 Replace the empty center box with `<WindowTitle />`

## 4. Style

- [x] 4.1 Add center title styling in `style.scss` (max-width, spacing)

## 5. Verify

- [x] 5.1 Run `ags run .` and confirm title appears in center
- [x] 5.2 Switch windows and confirm title updates
- [x] 5.3 Confirm long titles are truncated with ellipsis
- [x] 5.4 Confirm icon matches the focused app
