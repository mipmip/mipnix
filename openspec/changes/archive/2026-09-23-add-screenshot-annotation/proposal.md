<!-- Bean: .beans/mipnix-i4oy--replace-hyprland-screenshot-with-grimslurpsatty.md -->

## Why

A screenshot often needs an arrow on it before it is worth sending. Today there
is no way to draw one: the capture is saved, copied and announced, and from
there the only routes are opening it in an image editor by hand or retaking it
inside some other tool.

The bean asks to replace the capture pipeline with
`grim -g "$(slurp)" -t ppm - | satty ...`. Exploring it turned up a cost that
was not obvious from the one-liner. That command drops five things the deployed
flow already does:

| | deployed | the bean's one-liner |
|---|---|---|
| save location | `$HYPRSHOT_DIR`, `~/Afbeeldingen/Schermafbeeldingen` | `~/Pictures/Screenshots`, which does not exist here |
| clipboard | automatic `wl-copy` | none |
| notification | clickable, reveals the file | none |
| last-shot marker | yes, so `Ctrl+Shift+E` works | none |
| region picker | `slurp -d`, shows dimensions | plain `slurp` |

It also changes every capture into a two-step act: select the region, then deal
with an editor window, even for the common case of pasting straight into a chat.
28 screenshots have accumulated in `Schermafbeeldingen` since the capture flow
landed, and most of them never needed a mark on them.

So this change takes the bean's goal, annotation, and reaches it from the other
end. The capture stays instant. The notification gains a second action, and
annotation happens on a file that is already saved, already copied and already
safe. You decide whether to annotate after seeing the capture, which is the
moment you actually know.

## What Changes

- **A second action on the screenshot notification.** `shot-notify` gains
  `-A annotate=Bewerken` alongside the existing `-A default=Tonen`. In swaync a
  `default` action is the card body itself and draws no button, so today the
  notification is a plain clickable card; a second, named action makes
  `alt_actions_box` appear below it with a real button. The body keeps revealing
  the file, so nothing about the current behaviour changes.

- **A new `shot-annotate` script.** Opens satty on the already-saved capture,
  writes the annotated result back to the same path, refreshes the clipboard
  through `--copy-command wl-copy`, and suppresses satty's own notifications so
  one capture still produces one toast.

- **The activation token is forwarded to satty.** `shot-notify` already captures
  the XDG activation token swaync mints when an action fires, and passes it to
  `shot-reveal-last` as a `StartupId`. satty is a GTK window launched the same
  way and needs the same token, as `XDG_ACTIVATION_TOKEN`, or it opens without
  focus.

- **satty is installed**, at 0.20.1 from the pinned nixpkgs, alongside hyprshot
  in the Hyprland desktop module.

- **satty is configured declaratively** through
  `$XDG_CONFIG_HOME/satty/config.toml`, so the behaviour lives in the repo rather
  than in a long command line or in undeclared state on each machine.

## Capabilities

### Added Capabilities

- `screenshot-annotation`: a saved screenshot can be annotated from its own
  notification, with the annotated result replacing the original file and
  refreshing the clipboard, and with a capture that is never at risk if the
  annotation is abandoned.

## Impact

- `modules/USERS/pim/programs/hyprland/scripts/shot-notify`: add the second
  action and replace the single action comparison with a `case`.
- `modules/USERS/pim/programs/hyprland/scripts/shot-annotate`: new file.
- `modules/programs/desktop/de/hyprland.nix`: add `satty` to
  `environment.systemPackages`, next to `hyprshot` at line 105.
- A new home-manager file for `satty/config.toml`.
- No new keybind. The button is reached from the notification that already
  appears.
- Blast radius: `pim-hyprland` reaches cichorei, doornappel and peterspav through
  `modules/ROLES/home-pim-desktop.nix:26`. The package addition is NixOS-side, so
  this needs both a system rebuild and a home switch.

## Out of Scope

- **Replacing the capture pipeline.** hyprshot keeps both binds. This is a
  deliberate reading of the bean, recorded here so the two do not silently
  diverge: the bean says "replace ... with grim/slurp/satty", and this change
  instead adds satty after the existing capture. The reasoning is in "Why", and
  the alternatives considered are in `design.md`.
- **Window mode.** `Ctrl+Shift+W` stays on hyprshot. Its `grab_window` feeds
  candidate boxes from `hyprctl clients` into `slurp -r` and clamps against
  multi-monitor geometry; reimplementing that to remove one dependency is not a
  trade worth making.
- **Changing the notification thumbnail.** `-i <file>` puts the capture in the
  app-icon slot, which swaync's default theme renders as a small round badge
  (`border-radius: 100px` on `.notification-content .image`). A wide body image
  through the `image-path` hint would preview the capture properly. Tried live
  during exploration, and deliberately not adopted here.
- **A dedicated annotate keybind.** Considered as option B during exploration.
  The notification button covers the same need without another binding to learn.
- **Annotating anything other than the last capture.** `shot-annotate` takes a
  path, so it would work on any file, but nothing in this change offers a way to
  pick one.

## Assumptions

These were open during exploration. They are answered here so the change is
actionable, and each is cheap to revise.

- **satty can read and write the same path in one run.** The whole design rests
  on annotating in place. Task 2.1 checks it before anything depends on it.
- **Escape leaves the original untouched.** `--actions-on-escape exit` discards
  the annotation session without saving. This is the property that makes the
  design safe: the capture is already on disk and on the clipboard before satty
  opens, so abandoning an annotation costs nothing.
- **Enter saves and exits.** `--actions-on-enter save-to-file,exit` with
  `--early-exit`, so the common path is one keystroke.
- **The annotated file keeps the original name.** No `-annotated` suffix and no
  second file. The marker at `~/.cache/hyprshot/last` therefore stays valid and
  `Ctrl+Shift+E` still reveals the right thing.
- **The clipboard is refreshed, not left stale.** After annotating, the clipboard
  should hold the annotated image, otherwise pasting silently gives the
  unannotated one. `--copy-command wl-copy` handles it.
- **One toast per capture, still.** satty notifies on save by default, which
  would add a second toast on top of the one `shot-notify` already sent.
  `--disable-notifications` keeps the existing `screenshot-capture` guarantee
  intact.
- **No second notification after annotating.** The file is revealed or not by the
  action the user already took. Adding a confirmation toast for a thing the user
  just did by hand is noise.
