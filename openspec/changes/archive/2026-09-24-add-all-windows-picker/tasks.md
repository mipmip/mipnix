## 1. Widget

- [x] 1.1 Add `packages/mipbar/widget/AllWindows.tsx`, modelled on `Minimized.tsx`:
      `menubutton` + `popover` + `For each`, `lookupIcon` for the row icon, and the
      `withHexPrefix` address normalization (AstalHyprland returns addresses without
      the `0x` that `hyprctl … address:` requires — see `Minimized.tsx:30-34`).
- [x] 1.2 Build the row list from the full client set (`hyprland.get_clients()`), not
      by iterating workspaces. Row title falls back class → generic label when the
      title is empty.
- [x] 1.3 Left-click (`onClicked`) → go to the window: switch to its workspace and
      focus it, leaving it where it is. For a client on a special workspace, fall
      through to the bring-here action instead.
- [x] 1.4 Right-click → bring here: `movetoworkspace <current>,address:<addr>` then
      `focuswindow address:<addr>`. Use `Gtk.GestureClick` with
      `set_button(Gdk.BUTTON_SECONDARY)` and `add_controller`, following
      `Workspaces.tsx:103-108`. Ensure the secondary gesture does not also fire the
      primary handler.
- [x] 1.5 Wire the same Hyprland signals `Minimized.tsx` uses (`client-added`,
      `client-removed`, `client-moved`, `notify::workspaces`) to refresh the list.
- [x] 1.6 Indicator is always visible (unlike `Minimized`, which hides when empty).

## 2. Integration

- [x] 2.1 Import and place the widget in the `end` cluster of
      `packages/mipbar/widget/Bar.tsx`.
- [x] 2.2 Add indicator and row styles to `packages/mipbar/style.scss`, following the
      existing `.Minimized` / `.MinimizedRow` / `.MinimizedPopover` rules.

## 3. Verification

- [x] 3.1 **Settled by choosing the robust path rather than testing.** The
      single-dispatch optimization was not verified — testing it means moving focus
      on a live session, which was avoided during exploration for the same reason.
      The implementation uses `workspace <id>` then `focuswindow address:<addr>`,
      which is correct whether or not `focuswindow` crosses workspaces on its own.
      If someone later confirms it does, the `workspace` dispatch can be dropped.
- [x] 3.2 Verified at the data-source level against the live compositor via a
      read-only GJS probe of `AstalHyprland`: `get_clients()` returned 3 clients,
      matching `hyprctl clients -j | jq length` = 3, and **included the client on
      workspace id 10** — a workspace the bar's workspace row does not draw. Also
      confirmed `get_address()` returns the address without the `0x` prefix (so the
      `withHexPrefix` normalization is required) and that `get_workspace().get_id()`
      / `.get_name()` resolve. The GUI row-rendering pass still needs a switch.
- [ ] 3.3 Minimize a window via the `hypr-longpress` action; confirm it appears in
      this picker as well as in `Minimized`.
- [ ] 3.4 Left-click a row for a window on another workspace; confirm the view
      switches to that workspace, the window is focused, and
      `hyprctl clients -j` shows its `workspace.id` unchanged.
- [ ] 3.5 Right-click a row; confirm the window's `workspace.id` becomes the current
      workspace, it is focused, and the view did not switch elsewhere first.
- [ ] 3.6 Left-click a row for a window on `special:minimized`; confirm it is brought
      to the current workspace rather than flashing the special overlay.
- [ ] 3.7 Disconnect the external monitor with a window on one of its workspaces;
      confirm the window still lists and that right-click recovers it.
- [ ] 3.8 Open and close windows with the popover open; confirm rows appear and
      disappear without reopening it.
- [ ] 3.9 Close every window; confirm the picker shows an empty list and does not
      error.
