## Context

See `proposal.md` for motivation. This change lands on top of
`add-screenshot-reveal`, whose scripts are deployed and in daily use.

**What already exists, and works.** `shot-notify` runs as hyprshot's post-save
hook, writes the last-shot marker, then detaches and blocks on a notification:

```
shot-notify <path>
   writes ~/.cache/hyprshot/last
   setsid --fork self --wait-and-reveal <path>
        |
        action=$(notify-send "Schermafbeelding opgeslagen" "<basename>" \
                     -i <path> -a Hyprshot -t 5000 \
                     -A default=Tonen \
                     --activation-token-fd 3 3>"$token")
        |
        [[ "$action" == "default" ]] || exit 0
        shot-reveal-last "$path" "$(cat "$token")"
```

The single comparison on line 55 is the seam this change widens into a `case`.

**Verified live during exploration, on doornappel, before writing anything.**
A notification carrying both actions was sent to the running swaync and clicked
twice:

```
  clicked the button  ->  notify-send printed  annotate
  clicked the body    ->  notify-send printed  default
```

So the two keys discriminate correctly on this exact setup. The swaync default
theme confirms why the button appears only now:

```css
.notification-default-action:not(:only-child) {
  /* When alternative actions are visible */
  border-bottom-left-radius: 0px;
}
.notification-alt-actions {
  border-bottom-left-radius: var(--border-radius);
  padding: 4px;
}
```

With one `default` action the body is `:only-child` and no button row is drawn.
A second, named action creates `alt_actions_box` below it. Nothing needs styling.

**What satty 0.20.1 offers**, from its own `--help` in the pinned nixpkgs:

```
  -f, --filename              input, or '-' for stdin
  -o, --output-filename       save target; supports ~ and chrono specifiers
      --early-exit            exit after copy/save (not after "save as")
      --copy-command          command called on copy, e.g. wl-copy
      --actions-on-enter      save-to-clipboard | save-to-file | save-to-file-as
                              | copy-filepath-to-clipboard | exit
      --actions-on-escape     same set
      --disable-notifications
      --initial-tool          pointer | crop | line | arrow | rectangle | ...
  -c, --config                else $XDG_CONFIG_HOME/satty/config.toml
```

`--disable-notifications` matters: without it satty sends its own toast on save,
and the `screenshot-capture` spec already requires exactly one notification per
capture.

## Goals / Non-Goals

**Goals**

- Annotate a capture without leaving the notification that announced it.
- The fast path stays at zero extra keystrokes.
- An abandoned annotation cannot damage the capture.
- The annotated result is what a subsequent paste yields.
- One capture keeps producing one notification.

**Non-Goals**

- Replacing hyprshot, or touching how a capture is taken at all.
- An annotation history. satty overwrites; restic and the file manager are where
  older states live, if anywhere.
- Annotating arbitrary files. The entry point is a notification about a specific
  capture.

## Flow

```
Ctrl+Shift+R
     |
     v
hyprshot -m region --silent -- shot-notify        (unchanged)
     |
     +-- grim + wl-copy + ~/.cache/hyprshot/last  (unchanged)
     |
     v
notify-send ... -A default=Tonen -A annotate=Bewerken --activation-token-fd 3
     |
     |  ( ) Schermafbeelding opgeslagen          <- body = default
     |      2026-09-22-234902_hyprshot.png
     |  ------------------------------------
     |           [ Bewerken ]                    <- alt_actions_box
     |
     +-------------------+-------------------+
     |                   |                   |
   default            annotate            <empty>
     |                   |                   |
     v                   v                   v
shot-reveal-last    shot-annotate         exit 0
 (as today)              |             (timed out)
                         v
        XDG_ACTIVATION_TOKEN=<token> satty
            --filename        <path>
            --output-filename <path>       <- same file, in place
            --copy-command    wl-copy
            --disable-notifications
            --early-exit
                         |
              +----------+----------+
              |                     |
           Enter                 Escape
        save + exit            exit, no save
              |                     |
              v                     v
     file overwritten        original untouched
     clipboard refreshed     clipboard still holds the capture
```

## Decisions

### Annotation is an action on the notification, not a capture mode

Three shapes were weighed during exploration.

**A, replace the region bind.** One pipeline, one mental model, but every
capture then costs an editor window to dismiss. Most captures do not want a
mark on them, and the ones that do are not known in advance.

**B, a separate annotate keybind.** Keeps the fast path fast, but runs two
capture pipelines that have to stay in step on save location, clipboard,
notification and marker file. Two places for the same five concerns to drift.

**C, an action on the notification.** The fast path is untouched, there is one
capture pipeline, and the decision moves to the point where the information
exists: you have seen the capture. It also reuses a mechanism that is already
built, deployed and now demonstrated to work with two actions.

C wins on all three counts, and the thing that makes it viable is that the
notification already exists and already carries an action.

### The capture is saved before annotation begins

This falls out of C rather than being engineered, and it is the strongest safety
property of the design. By the time the button can be pressed, the file is on
disk, the image is on the clipboard, and the marker is written. satty operates
on a file that is already safe.

So `--actions-on-escape exit` is the correct discard: it leaves everything as it
was. There is no "unsaved capture" state to lose, which is exactly the state
shapes A and B both create.

### In place, same filename

satty writes back to the path it read. No `-annotated` suffix, no second file.

Two things depend on it. `~/.cache/hyprshot/last` already names the file, so
`Ctrl+Shift+E` keeps working with no coordination between the two scripts. And
the folder does not accumulate pairs of nearly-identical images, which is what a
suffix scheme produces in a directory that already holds 28 captures.

The cost is that the unannotated original is gone once you save. That is the
right default: the annotated version is the one you wanted, and the alternative
doubles the folder for a case that rarely matters.

### The token is forwarded, again

`shot-reveal-last` already takes an activation token and passes it as
`ShowItems`' `StartupId`, because under Wayland an application cannot focus
itself. satty has the same problem and the same solution, reached differently:
GTK reads `XDG_ACTIVATION_TOKEN` from the environment rather than taking an
argument.

Without it, satty opens behind the current window with an urgency hint, which
for a tool you just asked for by clicking a button is the wrong outcome.

### satty is configured in a file, not on the command line

`--copy-command`, `--actions-on-enter`, `--actions-on-escape`,
`--disable-notifications`, `--early-exit` and `--initial-tool` would make
`shot-annotate` a wall of flags. satty reads
`$XDG_CONFIG_HOME/satty/config.toml`, so the behaviour goes there, managed by
home-manager like the rest of the dotfiles, and the script keeps only what
varies per invocation: the two paths.

The flags stay available for anything the config file cannot express.

## Risks / Trade-offs

- **satty may not support reading and writing one path in a single run.** The
  design assumes it does. If it truncates the input before reading, the capture
  is destroyed rather than annotated. Task 2.1 tests this on a throwaway file
  before any wiring exists, and the fallback is a temporary file with an atomic
  move into place.

- **The annotated version replaces the original permanently.** Deliberate, see
  above, but it is a real loss if a mark is applied in error and noticed later.

- **A stale clipboard would be silent.** If `--copy-command` does not fire on
  the save path chosen, a paste after annotating yields the unannotated image
  with nothing to indicate it. Task 4.3 checks the clipboard specifically rather
  than trusting the flag.

- **Two toasts if satty's notifications are not suppressed.** Would break the
  existing `screenshot-capture` guarantee of one notification per capture.

- **The button is only reachable for the notification's lifetime**, 5 seconds.
  Unlike revealing, which also has the `Ctrl+Shift+E` fallback, a missed toast
  means opening the file by hand. Accepted: annotation is a deliberate act and
  the file is easy to reach through the reveal path.

- **satty's window may land somewhere unhelpful** under a tiling compositor.
  It has `--fullscreen`, `--resize` and `--floating-hack` for exactly this, none
  of which are set here. If it tiles badly in practice, that is a config-file
  change, not a redesign.

## Open Questions

None blocking. Task 2.1 settles the only one the design rests on.
