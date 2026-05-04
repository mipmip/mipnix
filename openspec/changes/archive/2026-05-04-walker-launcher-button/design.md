# Design: Walker Launcher Button

## Context

The bar currently has a placeholder "Welcome to pims AGS!" button in the start section. We need to replace it with a functional app launcher that opens walker, matching ashell's top-left launcher behavior.

Walker already runs as a D-Bus service (`walker --gapplication-service`) via hyprland autostart. Invoking `walker` simply activates the existing service instance.

## Goals / Non-Goals

**Goals**:
- Provide a single click-to-launch button for walker in the top-left
- Match ashell's UX: icon button, same position, same behavior

**Non-Goals**:
- Managing the walker service lifecycle
- Supporting alternative launchers
- Keyboard shortcut handling (already handled by hyprland binds)

## Decisions

### Use a `<button>` with a text label for the icon

Use a GTK `<button>` containing a `<label>` with the 󱗼 nerd font character, rather than a `<image>` with a symbolic icon.

**Why**: The nerd font icon matches ashell's existing icon exactly. Using a label avoids needing to ship or reference a separate icon file. The nerd font is already available in the system font stack.

**Alternative considered**: Using `Gtk.Image` with a symbolic icon name like `view-app-grid-symbolic`. Rejected because it wouldn't match ashell's look and depends on the icon theme.

### Use `execAsync` for launching

Call `execAsync("walker")` in the `onClicked` handler.

**Why**: Walker runs as a gapplication service, so this is effectively a D-Bus activation — instant and non-blocking. `execAsync` is already used in the codebase for the same pattern.

### Align to start, no expand

Set `halign={Gtk.Align.START}` and remove `hexpand` so the button sits flush-left rather than centering in the start section.

**Why**: Matches the expected top-left position for an app launcher. The current placeholder uses `hexpand` + `CENTER` alignment which spreads across the section.

## Risks / Trade-offs

[Risk] Nerd font icon may not render if font is missing → Mitigation: The same font renders fine in ashell on this system; this is the same font stack.

## Open Questions

None.
