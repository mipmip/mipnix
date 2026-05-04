# Design: DateTime Format

## Context

The bar's clock widget currently runs `date` with no format string, showing the full system default output. We want a compact Dutch-locale format: `ma 4 aug, 17:33`.

## Goals / Non-Goals

**Goals**:
- Show abbreviated Dutch weekday, day number, abbreviated month, and HH:MM
- Keep using the existing `createPoll` + shell command approach

**Non-Goals**:
- Changing the calendar popover
- JavaScript-based date formatting
- Locale-independent formatting

## Decisions

### Use `date` format string with LC_TIME override

Use `LC_TIME=nl_NL.UTF-8 date +"%a %-d %b, %H:%M"` as the poll command.

**Why**: Keeps the same `createPoll` pattern already in use. The locale env var ensures Dutch day/month names regardless of the system's default locale. `%-d` removes zero-padding from the day number.

**Alternative considered**: Using JavaScript `Date` with `toLocaleDateString`. Rejected because the shell command approach is already established and simpler for this case.

## Risks / Trade-offs

[Risk] `nl_NL.UTF-8` locale might not be generated on the NixOS system → Mitigation: Check `locale -a` during implementation; if missing, add to NixOS config.

## Open Questions

None.
