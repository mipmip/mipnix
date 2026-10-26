## Context

See proposal.md for motivation and the specs for the required behavior.

The session runs swaync 0.12.6 as the notification daemon, started from
`autostart.conf`. It has no configuration file in the repository or in the home
directory, and it owns both `org.freedesktop.Notifications` and its own
`org.erikreider.swaync.cc` control interface.

Three routes to notification content were investigated:

- AstalNotifd, the natural fit for an AGS bar. Its proxy checks the daemon name,
  vendor and version after `GetServerInformation` and refuses to attach when
  they differ from its own. With swaync running, it cannot be used without
  replacing swaync.
- The swaync control interface. It exposes a count, Do Not Disturb, visibility
  and `LatestInvokeAction`, but no notification text. `LatestInvokeAction` acts
  only on the latest floating toast, so an expired notification cannot be
  actioned through it.
- swaync scripts. They receive the summary, body and most hints, but the
  configuration model deliberately skips hints whose names contain "image" or
  "icon", and it does not expose the action list. A script therefore cannot
  reconstruct a screenshot card.

What does work is the session bus itself. `busctl --user monitor
org.freedesktop.Notifications --json=short` emits one JSON object per message,
and a `Notify` call carries every argument defined by the freedesktop
specification: application name, replaces id, icon, summary, body, actions and
hints. The reply to that call carries the notification id the daemon assigned.
Both were verified against a live notification.

The screenshot scripts are already in place. `shot-reveal-last` reveals a path
through `org.freedesktop.FileManager1` and `shot-annotate` opens satty on it.
Both accept an optional activation token, and the keybind path already runs
without one.

## Goals / Non-Goals

**Goals:**

- Capture notification content without changing the daemon or its configuration.
- Keep a bounded, scrollable list of recent notifications, newest first.
- Keep the capture independent of which notification daemon is installed.
- Survive a bar restart and a monitor hotplug, which recreate the bar window.
- Track replacements so one message does not produce two cards.
- Reuse the existing reveal and annotation scripts rather than duplicating their
  D-Bus and validation logic.

**Non-Goals:**

- Replacing swaync, or taking over `org.freedesktop.Notifications`.
- An unbounded archive, unread counts, or Do Not Disturb control. The list is a
  short history with a fixed limit.
- Replaying arbitrary application actions.
- Minting an activation token. The bar opens the file manager the same way the
  reveal keybind does, with the same focus caveat.
- A second notification centre. swaync keeps its own control centre; this list
  answers "what did I just miss" from the bar.

## Decisions

### Capture from the bus, not from the daemon

A single long-lived `busctl --user monitor org.freedesktop.Notifications
--json=short` process streams every method call and signal that involves the
notification service. Only lines that contain `"member":"Notify"`,
`"interface":"org.freedesktop.Notifications"` or `"reply_cookie"` are parsed; a
substring check happens before `JSON.parse`, so unrelated traffic costs almost
nothing.

The service filter still includes about seven lines per notification: the
notification call, its reply, `GetServerInformation` traffic, and swaync's own
`SubscribeV2` signal. This is small and bounded.

Rejected: Attaching to swaync through AstalNotifd. It would replace a working
daemon and change the notification experience, which the request does not ask
for.

Rejected: A swaync script that writes the notification to a file. It cannot see
the image path or the actions, so screenshot cards would be impossible. It also
adds a configuration file to a daemon that currently runs on defaults.

Rejected: Polling `swaync-client` or the control interface. Neither exposes
content.

The monitor sees the `Notify` call before the daemon renders it, so the bar
records the notification even if the daemon decides not to show a toast. That
matches "the notifications that were delivered", which is what the list is for.

### One capture owned by the app, not by the widget

`app.ts` already recreates the bar window when monitors are added or removed.
A monitor started inside the widget would be duplicated on every recreation.
The capture therefore lives in `state/notifications.ts`, started once from
`app.start`'s `main`, and exposes the list as an AGS state. The widget reads
that state and renders it; remounting the widget does not touch the process.
Both restart paths in `app.ts` stop the capture before they spawn the new bar,
because `app.quit()` calls `exit()` and would otherwise orphan the monitor.

If the monitor exits, the state module starts it again with a short delay, so a
swaync restart or a transient bus error does not leave the bar deaf.

### Persist a normalized, bounded list

The raw `Notify` arguments are normalized to a record: a stable key, the
notification id, the caller and D-Bus cookie used to match the reply,
application name, application icon, summary, body, image reference, action list
and arrival timestamp. The list is capped at 50, newest first, written to
`~/.cache/mipbar/notifications.json` after every change and read once at
startup.

The previous single-card cache, `last-notification.json`, is read once when the
new file is absent, converted to a one-entry list, written to the new file and
then removed. A user who upgrades keeps the notification that was on the card.

`image-data` hints are deliberately dropped. They can be several megabytes, and
serializing them on every notification would waste disk and time. Screenshots
use `image-path`, which points at the file on disk. A notification that only
carries `image-data` shows without an image.

The write goes through a temporary file in the same directory followed by a
rename, so an interrupted write cannot leave a half JSON file that the next
start would have to reject. The cache file is created with mode 0600.
Notification bodies can contain private text and this is the only place the bar
stores them.

### Identify and replace notifications

A `Notify` call includes a `replaces_id`, but a new notification has id 0 and
only learns its id from the daemon's reply. The record therefore starts with the
caller's unique bus name and the call's cookie, which together identify the
pending call. When the method return arrives, it carries `destination` (the
caller) and `reply_cookie`; the module maps those to the pending record, stores
the returned id, and publishes the list.

When a later `Notify` has `replaces_id > 0`, the entry with that id is removed
and the updated record is prepended. That is how an application that updates a
message keeps one card instead of adding a second. The pending map is only for
new notifications; a replacement already has an id.

This also works across processes: a replacement is matched by the daemon's id,
not by the sender, so any client updating that notification replaces the same
card.

### Screenshot detection by action shape

A notification is treated as a screenshot when its action list contains both
`default` and `annotate`. That pair is the contract `shot-notify` already uses,
so this works without looking at the application name, which is cosmetic and
could change. When the image path is missing, the recorded last capture from
`~/.cache/hyprshot/last` is used, as the reveal keybind does.

The two controls call the existing scripts through `$XDG_CONFIG_HOME/hypr/scripts`,
where the Hyprland module installs them. The bar does not inherit that directory
on `PATH`, so a bare command name would fail:

- card or image: `shot-reveal-last <path>`
- Bewerken: `shot-annotate <path>`

Both are called without an activation token. The scripts already accept that,
including their own error notifications for a missing file. Calling them keeps
one implementation of path validation and of the `FileManager1` call.

Rejected: Calling `gdbus` and `satty` directly from the widget. It duplicates
logic that the scripts own and would drift from the keybind behavior.

Rejected: Detecting the application by name `Hyprshot`. It is a display string,
not a contract, and the actions are the part that determines what can be done.

### A popover with a scrollable list

The control is a `menubutton` with a `popover`, following `Displays.tsx` and
`QuickSettings.tsx`. The popover has a header with the title and a clear-all
control, then a `Gtk.ScrolledWindow` that bounds the list at 420 pixels of
content height and scrolls when there are more cards. The window never scrolls
horizontally.

Each card shows the application name and a relative time in a header, the
summary in bold, the body as plain text, then the image and, for a screenshot,
the reveal and annotate controls. A generic card is a plain box, so clicking it
does nothing.

Bodies are stripped of markup before display. The freedesktop specification
allows markup, but a malformed body makes a GTK label with markup enabled render
nothing, and a notification is too transient to debug. Losing bold text is a
smaller cost than an empty card.

The image is shown through `Gtk.Picture` with a bounded height. A missing file
leaves the image area out rather than showing a broken icon.

Relative times are computed when the popover opens, so no timer runs while it is
closed.

### No badge, no count

The request is a way back to recent notifications, not an inbox. A count would
need a second stream from swaync and would compete with the existing toast for
attention. It can be added later without changing the capture or the list.

## Risks / Trade-offs

- Sensitive notification text is written to disk. Mitigation: file mode 0600, a
  clear-all control, a fixed limit of 50, and no attempt to copy notifications
  anywhere else.
- The monitor sees notifications for every application, including ones the user
  might not expect to be stored. Mitigation: a bounded list that drops the
  oldest, and a control that removes everything.
- Notifications that only carry `image-data` lose their image. Accepted, because
  the screenshot flow uses `image-path` and inline image data would bloat the
  cache.
- Markup in bodies is not rendered. Accepted, for the reason above.
- `busctl` must be on the bar's PATH. systemd provides it on every host in this
  repository. If it is missing, the capture logs the failure and the popover
  shows its empty state.
- Opening the file manager or satty from the bar can put the window behind the
  focused one, because there is no activation token. This matches the reveal
  keybind and is accepted.
- A replaced notification moves to the top of the list, because it is the newest
  content. Its old position is not preserved.
- The first start after upgrading reads the old single-notification cache once.
  If that file is unreadable, it is ignored and the list starts empty.

## Migration Plan

Deploy with the normal home-manager switch. Home Manager does not restart a
running bar, so restart it after the switch to pick up the new binary. On first
start the module reads
`~/.cache/mipbar/last-notification.json` if `notifications.json` does not exist,
writes the new list file and removes the old one. Rolling back means removing
the widget and deleting `~/.cache/mipbar/notifications.json`; the old cache file
will not be recreated, and no daemon configuration is touched.

## Open Questions

None.
