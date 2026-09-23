## Why

A screenshot lands on the clipboard and then effectively disappears. The file
exists, but every way back to it is manual.

**1. The notification is inert by construction.** `hyprshot` 1.3.0 builds its
toast without a single action:

```bash
notify-send "Screenshot saved" "${message}" \
            -t "$NOTIF_TIMEOUT" -i "${1}" -a Hyprshot
```

The freedesktop notification spec only makes a notification clickable when it
carries an action named `default`. This one carries none, so swaync renders a
dead card. Clicking it dismisses it. This is not a swaync setting that can be
turned on; the sending side has to change.

**2. Screenshots are dumped into the pictures folder.** `HYPRSHOT_DIR` is not
set anywhere in this repo, so hyprshot falls back to `XDG_PICTURES_DIR`, which
`~/.config/user-dirs.dirs` sets to `$HOME/Afbeeldingen`. 21 files named
`2026-09-21-230255_hyprshot.png` now sit there among ordinary pictures. Finding
the one taken eight seconds ago means sorting by date and reading timestamps.

**3. Once the toast expires, the file is gone from reach.** The notification
lives 5 seconds. After that there is no command, bind or marker that points at
the last screenshot. The only route is the file manager and a hunt by name.

The clipboard copy covers the common case of pasting straight into a chat
window. The cases it does not cover are the ones that hurt: attaching the file
to an email, renaming it before sharing, deleting a bad capture, or dragging it
into an application that will not take a paste.

## What Changes

- **Take ownership of the capture.** Both screenshot binds call a repo-owned
  wrapper instead of `hyprshot` directly. The wrapper runs `hyprshot --silent`
  and receives the saved path through hyprshot's `-- [command]` hook, so
  hyprshot keeps owning grim, the region picker, the clipboard copy and the
  filename; the repo owns only what happens afterwards.

- **Give screenshots their own folder.** `HYPRSHOT_DIR` is set to
  `~/Afbeeldingen/Schermafbeeldingen` in `hypr/envs.conf`, so bare `hyprshot`
  from a terminal lands in the same place as the bind.

- **Make the notification clickable.** The wrapper sends its own notification
  carrying `-A default=...`. swaync 0.12.6 renders a `default` action as the
  notification body itself, so the whole card becomes the click target with no
  button drawn.

- **Reveal the file on click**, via
  `org.freedesktop.FileManager1.ShowItems`. This is the "Show in Files" contract
  Nautilus implements: it opens the containing folder with the file already
  selected, reuses an existing window instead of spawning one, and is
  DBus-activated so Nautilus need not already be running.

- **Focus the revealed window properly.** swaync ships an XDG activation helper
  and hands out an activation token when an action fires. The wrapper forwards
  that token into the `StartupId` argument of `ShowItems`, which is what lets
  Hyprland raise and focus the Nautilus window rather than only flagging it
  urgent.

- **Add a standalone reveal bind** (`Ctrl+Shift+E`) for after the toast has
  expired. The wrapper records the path of each capture in
  `~/.cache/hyprshot/last`, and the bind reveals whatever that file names.

- **Fix the stale comment** at `binds.conf:56`, which says `(Ctrl+Shift+C)`
  above two binds on `R` and `W`.

## Capabilities

### Added Capabilities

- `screenshot-capture`: a screenshot is saved to a dedicated folder, copied to
  the clipboard, and announced by a notification whose body reveals the file in
  the file manager with the file selected. The last capture stays reachable by
  keybind after the notification has gone.

## Impact

- `modules/USERS/pim/programs/hyprland/scripts/shot-notify`: new file. Sends the
  notification, waits for the action, reveals the file, writes the last-shot
  marker.
- `modules/USERS/pim/programs/hyprland/scripts/shot-reveal-last`: new file.
  Reads the marker and reveals it. Also the reveal implementation `shot-notify`
  calls, so there is one copy of the DBus call.
- `modules/USERS/pim/programs/hyprland/hypr/binds.conf`: repoint the two
  screenshot binds at the wrapper, add the reveal bind, fix the comment.
- `modules/USERS/pim/programs/hyprland/hypr/envs.conf`: add `HYPRSHOT_DIR`.
- No new packages. `hyprshot` is already in `hyprland.nix:105`, `gdbus` comes
  with glib and `notify-send` with libnotify, both already on the session PATH.
- Blast radius: `pim-hyprland` is imported by `home-pim-desktop`
  (`modules/ROLES/home-pim-desktop.nix:26`), which cichorei, doornappel,
  peterspav and `_lego2` all use. Home-manager only, no NixOS rebuild, so a
  `home-manager switch` plus a Hyprland config reload is the whole deployment.

## Out of Scope

- **The GNOME screenshot binds.** `_gnome/desktop-shortcuts.nix:84` and `:101`
  bind `gnome-screenshot` in the GNOME session. GNOME is installed alongside
  Hyprland but is not the session in daily use, and GNOME's own screenshot UI
  already offers a "Show in Files" route.
- **Annotation and editing.** Wiring satty or swappy between grim and the save
  is a separate change with its own interaction design.
- **Replacing hyprshot.** grimblast and hyprshot solve the same problem;
  swapping them buys nothing here.
- **Patching hyprshot to emit the action itself.** That means maintaining an
  overlay of an upstream shell script for one line, and the wrapper is needed
  for the marker file anyway.
- **Migrating the 21 existing files** beyond the one-off move in the tasks. No
  script, no watcher, no compatibility shim for the old location.

## Assumptions

These were open during exploration. They are answered here so the change is
actionable, and each is cheap to revise.

- **A Dutch folder name.** `~/.config/user-dirs.dirs` is already Dutch
  (`XDG_PICTURES_DIR="$HOME/Afbeeldingen"`), so `Schermafbeeldingen` matches its
  neighbours. Change the one `env` line if English is wanted.
- **Body click, not a button.** `-A default=` makes the card itself the target.
  The evidence is the `notification-default-action` CSS class and the
  `default_action` symbol in the swaync 0.12.6 binary, plus a separate
  `alt_actions_box` for non-default actions. Task 3.2 confirms it by hand before
  anything depends on it. If the body turns out not to be clickable, the
  fallback is a named action, which draws a visible `Reveal` button and changes
  the gesture but nothing else in the design.
- **A 5 second notification life.** hyprshot's default, kept. The standalone
  bind is what covers a missed toast, so the timeout does not need to grow.
- **One waiting process per capture.** `notify-send -A` implies `--wait`, so a
  process lives until the click or the timeout. The wrapper detaches it from
  hyprshot so nothing blocks, and it is bounded by the 5 second timeout.
- **The reveal target is the containing folder.** `ShowItems` selects the file;
  it does not open it. Opening the image is what double-clicking the selection
  is for, and the clipboard already covers pasting.
- **No filename escaping.** The save folder has no spaces and hyprshot names
  files `%Y-%m-%d-%H%M%S_hyprshot.png`, so the `file://` URI needs no
  percent-encoding. A custom `-f` with spaces would break this; nothing in the
  repo passes one.
