> Work the sections in order. Section 3 is a hand test of the one assumption the
> interaction design rests on, and it comes before the scripts are written on
> purpose: if the notification body turns out not to be clickable, section 4
> changes shape and nothing built before it is wasted.
>
> Sections 3, 7 and 8 are acts at a live Hyprland session that no tool can
> perform. The change is NOT archived until they pass.

## 1. Give screenshots their own folder

- [x] 1.1 In `modules/USERS/pim/programs/hyprland/hypr/envs.conf`, add
      `env = HYPRSHOT_DIR,$HOME/Afbeeldingen/Schermafbeeldingen`. Comment why it
      is here and not `-o` on the bind: it covers `hyprshot` typed in a terminal
      as well, and it keeps the wrapper from having to know the save location.
- [x] 1.2 Switch the home profile and reload the Hyprland config
      (`hyprctl reload`). Take a screenshot with the existing `Ctrl+Shift+R`
      bind and confirm the file appears under
      `~/Afbeeldingen/Schermafbeeldingen/` and that hyprshot created the folder
      itself.

## 2. Move the existing screenshots out of the pictures folder

- [x] 2.1 Move `~/Afbeeldingen/*_hyprshot.png` into
      `~/Afbeeldingen/Schermafbeeldingen/`. There were 21 at the time of
      writing; check the count first and confirm nothing else matches the glob.
- [x] 2.2 Confirm `~/Afbeeldingen` now holds only ordinary pictures.

## 3. Settle the default-action question by hand

> The design assumes `-A default=` makes the notification body itself the click
> target, on the strength of the `notification-default-action` CSS class and the
> `default_action` symbol in the swaync 0.12.6 binary. Verify it before building
> on it.

- [x] 3.1 In a terminal, run:
      `notify-send "test" "click the card" -A default=OK -t 10000`
      The command blocks.
- [x] 3.2 Click the notification body, not any button. Confirm the terminal
      prints `default` and the command exits. Record whether swaync drew a
      visible button, and whether the whole card was clickable.
- [x] 3.3 If the body was NOT clickable, stop and revise `design.md`: the action
      becomes a named one (`-A reveal=Tonen`), the gesture becomes a button
      press, and the `actionable-notification` scenarios in the spec need their
      wording adjusted. Everything else in the change is unaffected.
- [x] 3.4 Confirm the activation token arrives too. Re-run with
      `--activation-token-fd 3 3>/tmp/token`, click, and check `/tmp/token` is
      non-empty. If it is empty, `ShowItems` gets an empty `StartupId` and the
      revealed window may not take focus; note it and continue.

## 4. Write the reveal script

- [x] 4.1 Create `modules/USERS/pim/programs/hyprland/scripts/shot-reveal-last`.
      Follow the house pattern of its neighbours: `#!/usr/bin/env bash`,
      `set -euo pipefail`, a header comment explaining what it is for and why it
      uses DBus rather than `nautilus --select`.
- [x] 4.2 Signature: `shot-reveal-last [PATH] [ACTIVATION_TOKEN]`. With no
      `PATH`, read `~/.cache/hyprshot/last`. Both arguments optional.
- [x] 4.3 Reveal via
      `gdbus call --session --dest org.freedesktop.FileManager1
      --object-path /org/freedesktop/FileManager1
      --method org.freedesktop.FileManager1.ShowItems "['file://$path']" "$token"`,
      passing an empty string for the token when there is none.
- [x] 4.4 Handle the two empty cases with a notification rather than a silent
      exit: no marker file yet, and a marker naming a file that no longer
      exists.
- [x] 4.5 Test it directly: `~/.config/hypr/scripts/shot-reveal-last <a png>`
      opens the folder with that file selected. Then test the no-argument form
      against a hand-written marker file.

## 5. Write the notification script

- [x] 5.1 Create `modules/USERS/pim/programs/hyprland/scripts/shot-notify`, same
      house pattern. Header comment records the two non-obvious constraints:
      hyprshot calls this hook synchronously, and `notify-send -A` implies
      `--wait`, so the notification must be detached or hyprshot parks.
- [x] 5.2 Signature: `shot-notify PATH`, the path hyprshot passes.
- [x] 5.3 Write `~/.cache/hyprshot/last` in the foreground, creating the
      directory. Do this BEFORE detaching, so `Ctrl+Shift+E` works even when the
      notification cannot be sent.
- [x] 5.4 Detach the rest with `setsid`, not a bare `&`, so it leaves hyprshot's
      process group and hyprshot can exit.
- [x] 5.5 In the detached part, send the notification: Dutch summary, the
      captured image as `-i`, `-a Hyprshot`, `-t 5000`, `-A default=Tonen`, and
      `--activation-token-fd` writing to a temp file. Use the action name
      settled in task 3.
- [x] 5.6 On activation, call `shot-reveal-last` with the captured path and the
      token. Pass the path explicitly rather than letting it read the marker, so
      an older notification reveals its own file.
- [x] 5.7 Clean up the temp token file on every exit path.

## 6. Wire the binds

- [x] 6.1 In `modules/USERS/pim/programs/hyprland/hypr/binds.conf`, repoint both
      screenshot binds through the wrapper:
      `hyprshot -m region --silent -- ~/.config/hypr/scripts/shot-notify` and
      the same for `-m window`.
- [x] 6.2 Add `bind = Control_L SHIFT, E, exec, ~/.config/hypr/scripts/shot-reveal-last`.
      `Control_L SHIFT, E` is free; `Control_L SHIFT, L` is taken by
      `movewindow, mon:r` at `binds.conf:28`.
- [x] 6.3 Fix the comment at `binds.conf:56`. It reads
      `# Screenshot with hyprshot (Ctrl+Shift+C)` above two binds on `R` and
      `W`. Name the three binds it now heads.
- [ ] 6.4 Switch the home profile and `hyprctl reload`.

## 7. Verify the whole path by hand

- [x] 7.1 `Ctrl+Shift+R`, select a region. Confirm exactly ONE notification
      appears, with the capture as its thumbnail.
- [x] 7.2 Click it. Confirm Nautilus opens the screenshot folder, with the new
      file selected, and that the window is focused rather than only marked
      urgent.
- [ ] 7.3 Confirm the image is still on the clipboard: paste it somewhere.
- [ ] 7.4 With Nautilus already open on another folder, take a shot and click
      the notification. Confirm no second window is spawned.
- [ ] 7.5 Close Nautilus entirely. Take a shot, click the notification, confirm
      it starts and reveals.
- [ ] 7.6 Take a shot and let the notification expire. Confirm no window opens
      and that `pgrep -af 'shot-notify --wait-and-reveal'` is empty afterwards.
      That is the process to watch, not `notify-send`: the detached handler
      shows up under its own name with `notify-send` as its child.
- [ ] 7.7 `Ctrl+Shift+E` after all that. Confirm it reveals the most recent
      capture.
- [ ] 7.8 `Ctrl+Shift+W` on a window. Confirm the same behaviour.

## 8. Verify the edge cases from the spec

- [ ] 8.1 Take two screenshots in quick succession, both notifications on
      screen. Click the OLDER one. Confirm it reveals its own file, not the
      newer one.
- [ ] 8.2 Take a shot, then delete the file, then press `Ctrl+Shift+E`. Confirm
      a notification says so and no file manager window opens.
- [ ] 8.3 Delete `~/.cache/hyprshot/last`, press `Ctrl+Shift+E`. Confirm the
      same graceful message.
- [ ] 8.4 `pkill swaync`, take a screenshot. Confirm the file is saved, the
      clipboard has the image, nothing errors visibly, and `Ctrl+Shift+E` still
      reveals it. Then restart swaync.
- [ ] 8.5 Take a screenshot, then immediately check that no `hyprshot` process
      is left running while the notification is still on screen.

## 9. Build and validate

- [x] 9.1 `openspec validate add-screenshot-reveal --strict`.
- [x] 9.2 Build the affected home configurations. `pim-hyprland` reaches
      cichorei, doornappel, peterspav and `_lego2` through
      `modules/ROLES/home-pim-desktop.nix:26`.
      Two things to know before building. The repo needs `--impure`: the
      unrelated `pim-awscli-dir` module reads `~/.aws/other_accounts.json`,
      which pure evaluation forbids. And `git add` the two new scripts first: a
      flake build only sees tracked files, so while they are untracked the
      build succeeds and silently omits them from `hm_scripts`.
- [x] 9.3 Confirm no package was added: the diff touches only `envs.conf`,
      `binds.conf` and two new files under `scripts/`.
