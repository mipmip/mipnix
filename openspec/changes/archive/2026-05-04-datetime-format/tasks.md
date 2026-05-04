# Tasks: DateTime Format

## 1. Update Clock Format

- [x] 1.1 Change the `createPoll` command in `widget/Bar.tsx` to `LC_TIME=nl_NL.UTF-8 date +"%a %-d %b, %H:%M"`
- [x] 1.2 Verify `nl_NL.UTF-8` locale is available on the system

## 2. Verify

- [x] 2.1 Run `ags run .` and confirm the clock shows format like `ma 4 aug, 17:33`
- [x] 2.2 Confirm the calendar popover still works when clicking the time
