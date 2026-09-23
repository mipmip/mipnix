## Context

See `proposal.md` for motivation. The constraints that shape the approach, all
verified on `cichorei` while exploring:

**What hyprshot 1.3.0 gives us.** Reading the unwrapped script
(`/nix/store/kza22sr...-hyprshot-1.3.0/bin/.hyprshot-wrapped`):

```
save_geometry():
    grim -g "$geometry" "$SAVE_FULLPATH"
    wl-copy --type image/png < "$SAVE_FULLPATH"
    [ -z "$COMMAND" ] || "$COMMAND" "$output"     <- our hook, path as $1
    send_notification "$output"                   <- suppressed by --silent

send_notification():
    notify-send "Screenshot saved" "$message" \
                -t "$NOTIF_TIMEOUT" -i "$1" -a Hyprshot
                                                  ^ no -A, so no action, so
                                                    no click target
```

Two flags matter: `-s/--silent` skips the notification, and everything after
`--` becomes `$COMMAND`, invoked with the saved path. The hook fires *before*
the notification, which is why suppressing one and sending our own from the hook
gives a single toast rather than two.

The hook is called synchronously. Anything slow or blocking in it holds hyprshot
open, and `notify-send -A` blocks by design (`-A` implies `--wait`).

**What swaync 0.12.6 gives us.** Symbols in the binary:

```
  default_action               notification-default-action  (CSS class)
  default-action               alt_actions_box              (other actions)
  ActionInvoked                hide-on-action               (config schema)
  XdgActivationHelper          get_activation_token
  ActivationToken (dbus signal)
```

So swaync distinguishes the default action (the body) from the rest (buttons in
`alt_actions_box`), and it can mint an XDG activation token when an action
fires. Both are needed: the first for the click gesture, the second for focus.

**What the desktop gives us.** `org.freedesktop.FileManager1` is present and
DBus-activatable. Introspected live:

```
interface org.freedesktop.FileManager1 {
  ShowFolders(in as URIs, in s StartupId);
  ShowItems(in as URIs, in s StartupId);          <- reveal with selection
  ShowItemProperties(in as URIs, in s StartupId);
}
```

`ShowItems` is the interface behind "Show in Files" everywhere. It is worth
preferring over `nautilus --select` for three reasons: it reuses an open window
instead of spawning a second one, it activates Nautilus over DBus so it need not
be running, and it names no file manager, so `$fileManager` in `00-vars.conf`
could change without touching this code.

**Where things go.** `modules/USERS/pim/programs/hyprland/default.nix:32` sources
the whole `scripts/` directory into `~/.config/hypr/scripts`, so a new script is
a new file and nothing else. The neighbours (`theme-wallpaper`,
`workspace-monitor-rehome`) are plain `#!/usr/bin/env bash` with
`set -euo pipefail` and a header comment explaining themselves, resolving tools
from the session PATH.

## Goals / Non-Goals

**Goals**

- Clicking the screenshot notification opens the containing folder with the file
  selected and the window focused.
- The last screenshot stays reachable after the notification is gone.
- Screenshots live somewhere other than the pictures folder.
- hyprshot keeps owning capture. The repo owns only what happens after the file
  exists.

**Non-Goals**

- Any change to how the image is captured, named or copied.
- A screenshot history, gallery or manager. One path, one marker file.
- Working under any notification daemon other than swaync, or any file manager
  other than one implementing `FileManager1`. Both are single-daemon facts of
  this session, not variables.

## Flow

```
Ctrl+Shift+R
     |
     v
hyprshot -m region --silent -- ~/.config/hypr/scripts/shot-notify
     |
     +-- grim  -> ~/Afbeeldingen/Schermafbeeldingen/<ts>_hyprshot.png
     +-- wl-copy (png on the clipboard, unchanged)
     |
     +-- shot-notify "<path>"          (synchronous hook)
             |
             +-- write ~/.cache/hyprshot/last
             |
             +-- detach, return immediately  ---------> hyprshot exits
                     |
                     v
              notify-send "Schermafbeelding opgeslagen"
                 -i <path>  -a Hyprshot  -t 5000
                 -A default=Tonen
                 --activation-token-fd 3
                     |
             (blocks up to 5s)
                     |
          +----------+-----------+
          |                      |
     timeout, no output      body clicked
          |                      |
        exit 0            stdout = "default"
                          fd 3   = activation token
                                 |
                                 v
                    shot-reveal-last <path> <token>
                                 |
                                 v
              gdbus call --session
                --dest org.freedesktop.FileManager1
                --object-path /org/freedesktop/FileManager1
                --method ...ShowItems
                "['file://<path>']" "<token>"
                                 |
                                 v
                    Nautilus: folder open, file selected, focused


Ctrl+Shift+E  ->  shot-reveal-last          (no argument)
                       |
                       +-- read ~/.cache/hyprshot/last
                       +-- same ShowItems call, empty StartupId
```

## Decisions

### One reveal implementation, two entry points

`shot-reveal-last` takes an optional path and an optional activation token. With
no path it reads the marker. `shot-notify` calls it with both. The `gdbus`
incantation therefore exists once.

The alternative, inlining the DBus call in both scripts, means two places to fix
when the URI handling or the interface name changes. Not worth it for three
saved lines.

### The hook detaches; hyprshot must not wait

`notify-send -A` waits for the click. hyprshot calls the hook synchronously.
Left alone, every capture leaves a hyprshot process parked for the notification
lifetime, and `checkRunning` in hyprshot means a second capture during that
window behaves unpredictably.

`shot-notify` therefore does its one fast thing (write the marker) in the
foreground and detaches the notification into a background process that survives
the parent. `setsid` is the mechanism; a bare `&` would leave it in hyprshot's
process group.

Bounded by the notification timeout, so the worst case is one short-lived
process per capture, with no accumulation.

### The activation token is forwarded, not invented

Under Wayland an application cannot focus itself; it needs a token from whoever
the user interacted with. swaync mints one when the action fires and offers it
over `--activation-token-fd`. `ShowItems` has a `StartupId` parameter, which is
exactly where such a token belongs.

Skipping this is the difference between Nautilus coming to the front and
Nautilus opening behind the current window with an urgency hint. The standalone
`Ctrl+Shift+E` bind has no token to forward (it is a keybind, not a notification
action) and passes an empty string, which is the documented "no startup
notification" value.

### `HYPRSHOT_DIR` in `envs.conf`, not `-o` in the bind

Both work for the bind. Only the environment variable also covers `hyprshot`
typed into a terminal, and only it keeps the wrapper ignorant of the save
location, which matters because the wrapper learns the path from hyprshot rather
than computing it. One value, one place, no duplicated naming logic.

### `default` as the action name

The freedesktop spec reserves the key `default` for "the user activated the
notification itself". swaync's `notification-default-action` CSS class confirms
it styles the body for this. Any other key, for example `-A reveal=Tonen`, would
draw a button in `alt_actions_box` and leave the body inert, which is not the
gesture the change is about.

This is the one assumption load-bearing enough to test by hand before the rest
is built. Task 3.2 does that.

## Risks / Trade-offs

- **The default-action gesture is unverified on a live session.** Binary
  symbols are strong evidence, not proof. Mitigated by testing it standalone
  (task 3.2) before wiring anything. Fallback is a named action and a visible
  button; everything else in the design survives unchanged.

- **swaync not running means no notification and no reveal.** `notify-send`
  fails, the detached subshell dies, and the capture still happened, was saved
  and was copied. The marker file is written before detaching, so
  `Ctrl+Shift+E` still works. Degradation is partial by construction.

- **The marker can go stale.** Delete the file it names and `Ctrl+Shift+E`
  points at nothing. The script checks existence and says so through a
  notification rather than failing silently.

- **A second capture during the 5 second window replaces the marker.** Correct
  behaviour ("last screenshot"), but the first notification, if still on screen,
  now reveals through its own captured path rather than the marker. This is why
  `shot-notify` passes the path explicitly instead of letting the handler read
  the marker.

- **The old location keeps 21 files.** Nothing reads them, nothing migrates them
  automatically. A one-off move is in the tasks; if it is skipped, the only cost
  is that they stay where they are.

## Open Questions

None blocking. Task 3.2 settles the only one that was.
