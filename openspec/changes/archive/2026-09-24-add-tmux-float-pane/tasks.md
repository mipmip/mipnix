## 1. Registry support

- [x] 1.1 Add a `menu` field to the hotkey entry schema, defaulting to true, and verify an entry that omits it still reaches the menu unchanged
- [x] 1.2 Filter the tmux menu emitter by that field, and verify an entry with `menu = false` produces a `bind` line but no menu row
- [x] 1.3 Verify an entry with `menu = false` still appears in the generated keyb and myhotkeys sheets
- [x] 1.4 Add the build-time check that rejects a menu-bound key whose row name would begin with `-`, and verify registering `-` without `menu = false` fails naming the entry while registering it with `menu = false` succeeds
- [x] 1.5 Verify the generated tmux config is otherwise byte-identical to the current one, so the field changes nothing for existing entries

## 2. Toggle on

- [x] 2.1 Write the float-toggle launcher as a `writeShellScriptBin` beside the existing three, and verify `nix build` of the home configuration succeeds
- [x] 2.2 Create the hidden session with a placeholder running `sleep infinity` and `status off`, and verify the session exists and is detached
- [x] 2.3 Swap the current pane into the hidden session, and verify the pane id moves there while the placeholder takes its slot
- [x] 2.4 Zoom the placeholder, and verify `window_zoomed_flag` is 1 and the window shows one blank pane
- [x] 2.5 Store the pane id, placeholder id, outer client tty and width in global user options, and verify each is readable afterwards
- [x] 2.6 Record whether the window was already zoomed, and verify the flag is stored before the placeholder is zoomed
- [x] 2.7 Open the popup against the stored client, and verify the floated pane is visible and accepts input

## 3. Toggle off

- [x] 3.1 Detect the float by the hidden session existing, and verify the toggle takes the restore path when it does
- [x] 3.2 Unzoom the placeholder's window when it is zoomed, and verify the layout is visible again before the swap
- [x] 3.3 Swap the pane back, and verify `window_layout` is byte-identical to the string captured before floating
- [x] 3.4 Guard the session removal on the remaining pane being the stored placeholder id, and verify the session survives when the swap did not put the pane back
- [x] 3.5 Remove the session and unset every float option, and verify no float session is listed and no option remains
- [x] 3.6 Re-zoom the window when it was zoomed before floating, and verify the zoom state matches what it was

## 4. Width control

- [x] 4.1 Write the resize launcher taking a signed step, and verify it exits without error when no float exists
- [x] 4.2 Clamp the width to 20-100 and store it, and verify repeated steps stop at each bound
- [x] 4.3 Reopen the popup against the stored outer client after waiting for the hidden session to have no client, bounded by a timeout, and verify the popup returns at the new width
- [x] 4.4 Verify the stored width is used the next time a pane is floated

## 5. Bindings

- [x] 5.1 Register the toggle on `F` with `menu = false` left at its default, and verify it appears in `prefix + ?`
- [x] 5.2 Register `+` as a conditional acting only inside the float, with `menu = false`, and verify the bind line is accepted by tmux and no menu row exists
- [x] 5.3 Register `-` as a conditional with `delete-buffer` as the fallback and `menu = false`, and verify `tmux list-keys` shows the conditional form
- [x] 5.4 Verify `f` is still `find-window -Z` and that no existing registered key changed

## 6. Acceptance

- [x] 6.1 In a window with three or more panes, float a middle pane and verify the popup shows it, the background is blank, and a long-running process inside keeps running
- [x] 6.2 Press `+` and `-` inside the float and verify the width changes in steps of 10 and stops at 20 and 100
- [x] 6.3 Press `-` outside the float and verify it deletes a buffer as before
- [x] 6.4 Toggle off from inside the popup and verify the pane returns to the same slot and size and no float session is listed
- [x] 6.5 Detach from inside the popup, then toggle, and verify the pane is restored
- [x] 6.6 Float from an already-zoomed window, toggle back, and verify the window is zoomed again
- [x] 6.7 Rebuild with `./RUNME.sh up_home`, reload tmux, and verify every check above holds against the built configuration
