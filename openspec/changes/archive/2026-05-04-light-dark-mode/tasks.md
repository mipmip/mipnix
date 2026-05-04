## 1. Define Custom Themes

- [x] 1.1 Remove color values from `style.scss`, keep only layout/structure
- [x] 1.2 Create `theme.ts` with explicit dark and light CSS color definitions
- [x] 1.3 Apply theme CSS on top of base styles in `app.ts`

## 2. Watch for Color Scheme Changes

- [x] 2.1 Read initial color scheme via `exec("gsettings get ...")`
- [x] 2.2 Watch for changes via `subprocess("gsettings monitor ...")`
- [x] 2.3 On change, reset CSS and re-apply base styles + correct theme

## 3. Verify

- [x] 3.1 Run in dark mode and confirm hover/active/focused states look correct
- [x] 3.2 Switch to light mode and confirm the bar updates automatically
- [x] 3.3 Confirm screenshare indicator is visible in both modes
