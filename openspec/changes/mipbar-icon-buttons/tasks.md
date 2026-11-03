## 0. Spec repair

- [x] 0.1 Fix `openspec/specs/bar-visual-style/spec.md`: replace the stray `## ADDED Requirements` header with `## Purpose` and `## Requirements`, so the archive can merge this change

## 1. Shared icon button

- [x] 1.1 Measure the system monitor button's padding and size and write the `BarIcon` rule in `packages/mipbar/style.scss`
- [x] 1.2 Remove `.StatusIcon button { all: unset }` and the outer padding from `.StatusIcon`
- [x] 1.3 Add `BarIcon` to the clickable of Notifications, Displays, SshKey, Minimized, AllWindows, Caffeine, Camera, Screenshare and SystemMonitor

## 2. Colours and alignment

- [x] 2.1 Move keep-awake on to the indicator red in `theme.ts` for both themes; drop the amber rule
- [x] 2.2 Nudge the coffee glyph 1px down
- [x] 2.3 Give camera and screen share the same icon size

## 3. Test

- [x] 3.1 Add a test that every end-section icon widget carries `BarIcon` and that `style.scss` does not unset bar icon buttons
- [x] 3.2 Run the mipbar tests

## 4. Rollout

- [ ] 4.1 Commit and `rme up_home` on delliebellie
- [ ] 4.2 User: hover every icon, same rounded area everywhere
- [ ] 4.3 User: keep-awake on is red, coffee sits in line
