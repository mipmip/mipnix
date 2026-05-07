## 1. Fixed Workspace List

- [x] 1.1 Change `getWorkspaceItems` to always return items for IDs `[1, 2, 3, 4, 5, 6, 7, 8, 9, 0]`, looking up Hyprland workspace objects where they exist
- [x] 1.2 Add `isGroupStart` between workspace 7 and 8 (monitor group separator)
- [x] 1.3 Add `isLaptop` flag for workspaces 8, 9, 0

## 2. Styling

- [x] 2.1 Add CSS class `laptop` to laptop workspace buttons in Workspaces.tsx
- [x] 2.2 Add laptop accent background color in `theme.ts` for both dark and light mode
- [x] 2.3 Add light mode workspace container background in `theme.ts`

## 3. Verification

- [x] 3.1 Verify mipbar builds successfully
- [x] 3.2 Test in both dark and light mode
