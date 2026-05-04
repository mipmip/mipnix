# DateTime Format

**Bean**: [mipbar-kzjl](../../../.beans/mipbar-kzjl--datetime-most-right-1.md)
**Status**: proposed

## Summary

Format the clock widget to show Dutch-locale abbreviated date and time: `ma 4 aug, 17:33`.

## Motivation

The current clock just runs `date` which outputs the full system default format. The bar should show a compact, Dutch-formatted datetime that fits the bar aesthetic.

## Design

Change the `createPoll` command from `"date"` to a `date` invocation with a format string and Dutch locale.

```
┌──────────────────────────────────────────────────────┐
│ [󱗼] [Workspaces]                     ma 4 aug, 17:33│
│                                       └── click → 📅 │
└──────────────────────────────────────────────────────┘
```

### Changes

**`widget/Bar.tsx`**
- Change the `createPoll` command from `"date"` to `LC_TIME=nl_NL.UTF-8 date +"%a %-d %b, %H:%M"` to produce the desired format
- Optionally increase poll interval from 1000ms to 60000ms since seconds are no longer displayed

## Assumptions

- `nl_NL.UTF-8` locale is available on the system (NixOS)
- The calendar popover already works and needs no changes

## Capabilities

### Modified Capabilities

- `datetime-display` — Clock now shows Dutch-locale abbreviated date and time instead of raw `date` output

## Non-goals

- Changing the calendar popover behavior (already working)
- Making the format configurable
- Adding timezone display

## Tasks

1. Update the `createPoll` command in `widget/Bar.tsx` to use Dutch-locale formatted date
