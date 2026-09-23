> Work the sections in order. Section 2 is a hand test of the one assumption the
> whole design rests on, and it comes before any wiring: if satty cannot read and
> write the same path in one run, section 4 changes shape and nothing built
> before it is wasted.
>
> Sections 5 and 6 are acts at a live Hyprland session that no tool can perform.
> The change is NOT archived until they pass.
>
> **Note on sequencing.** This builds on `add-screenshot-reveal`, whose scripts
> are deployed and in daily use but which is not archived. Its `screenshot-capture`
> capability is therefore still a delta spec rather than a main spec, which is why
> the second action here is specified under a new capability rather than as a
> modification. Reconcile the two when that change archives.

## 1. Install satty

- [x] 1.1 Add `satty` to `environment.systemPackages` in
      `modules/programs/desktop/de/hyprland.nix`, next to `hyprshot` at line 105.
      Pinned nixpkgs carries 0.20.1.
- [x] 1.2 Rebuild and confirm `satty --version` reports 0.20.1.

## 2. Settle the in-place question by hand

> The design assumes satty can read and write the same path in a single run. If
> it truncates the input before reading, the capture is destroyed rather than
> annotated. Verify before building on it.

- [x] 2.1 Copy a screenshot to a throwaway path. Run
      `satty --filename <tmp> --output-filename <tmp>` on it, draw one mark,
      save, and confirm the file now holds the annotated image and is not
      truncated or empty.
- [x] 2.2 If it does NOT work in place, stop and revise `design.md`:
      `shot-annotate` writes to a temporary file and moves it over the original
      atomically. Everything else in the change is unaffected.
- [x] 2.3 While satty is open, note how its window lands under Hyprland. If it
      tiles unhelpfully, record it for task 3.2; `--fullscreen`, `--resize` and
      `--floating-hack` exist for this.
- [x] 2.4 Confirm `--actions-on-escape exit` leaves the file untouched, and that
      `--actions-on-enter save-to-file,exit` with `--early-exit` saves and closes
      in one keystroke.

## 3. Configure satty declaratively

- [x] 3.1 Add a home-manager file for `$XDG_CONFIG_HOME/satty/config.toml`
      carrying the behaviour: copy command `wl-copy`, the enter and escape
      actions settled in task 2.4, notifications disabled, early exit. Comment
      why it is a file and not a wall of flags on the command line.
- [x] 3.2 Add any window-placement option task 2.3 showed was needed. Leave it
      out if the window behaved.
- [x] 3.3 Switch and confirm the file is in place and that a bare
      `satty --filename <x> --output-filename <x>` now behaves as configured with
      no flags.

## 4. Wire the button

- [x] 4.1 Create `modules/USERS/pim/programs/hyprland/scripts/shot-annotate`,
      following the house pattern of its neighbours: `#!/usr/bin/env bash`,
      `set -euo pipefail`, a header comment explaining what it is for.
- [x] 4.2 Signature: `shot-annotate PATH [ACTIVATION_TOKEN]`. Pass the token as
      `XDG_ACTIVATION_TOKEN` in satty's environment, not as an argument: GTK
      reads it from the environment, unlike `ShowItems`, which takes a
      `StartupId` parameter. Without it satty opens unfocused.
- [x] 4.3 Handle the missing-file case with a notification rather than a silent
      exit, matching `shot-reveal-last`.
- [x] 4.4 In `shot-notify`, add `-A annotate=Bewerken` after the existing
      `-A default=Tonen`.
- [x] 4.5 Replace the single `[[ "$action" == "default" ]] || exit 0` comparison
      with a `case` over `default`, `annotate` and everything else. Keep the
      explicit `exit 0` at the end of the branch: without it execution falls
      through into the hook path and the script re-detaches itself forever.
- [x] 4.6 Leave `-i "$file"` alone. The round icon-sized thumbnail is the chosen
      behaviour; the body-image alternative is out of scope.
- [x] 4.7 Switch and `hyprctl reload`.

## 5. Verify the flow by hand

- [x] 5.1 `Ctrl+Shift+R`, select a region. Confirm the notification now shows a
      visible `Bewerken` button below the body.
- [x] 5.2 Click the body. Confirm Nautilus opens with the file selected, exactly
      as before, and that no annotation tool opens.
- [x] 5.3 Take another. Click `Bewerken`. Confirm satty opens on that capture and
      that its window has focus rather than only an urgency hint.
- [x] 5.4 Draw a mark and save. Confirm the file at the original path now holds
      the annotated image.
- [x] 5.5 Confirm no second file was created in
      `~/Afbeeldingen/Schermafbeeldingen/`.
- [ ] 5.6 Paste into something that accepts images. Confirm the ANNOTATED image
      is pasted, not the original.
- [x] 5.7 Press `Ctrl+Shift+E`. Confirm it reveals the annotated file.
- [x] 5.8 `Ctrl+Shift+W` on a window. Confirm the same button appears and the
      same flow works.

## 6. Verify the safety properties

> These are the reason the design annotates after saving rather than before.
> Test them deliberately rather than trusting the configuration.

- [ ] 6.1 Take a shot, click `Bewerken`, draw a mark, then press Escape. Confirm
      the file on disk is the UNANNOTATED original.
- [ ] 6.2 After that abandon, paste. Confirm the clipboard still holds the
      unannotated capture.
- [ ] 6.3 After that abandon, press `Ctrl+Shift+E`. Confirm the original is
      revealed.
- [ ] 6.4 Count the notifications through a full capture-annotate-save cycle.
      Confirm exactly ONE appeared, with no toast from satty and none confirming
      the save.
- [ ] 6.5 Take two screenshots in quick succession with both notifications on
      screen. Click `Bewerken` on the OLDER one. Confirm satty opens ITS file,
      not the newer capture.
- [ ] 6.6 Take a shot and let the notification expire untouched. Confirm no satty
      window appears and that
      `pgrep -af 'shot-notify --wait-and-reveal'` is empty afterwards.
- [ ] 6.7 Confirm the fast path is unchanged: take a shot, ignore the
      notification, and check the file is saved and the clipboard holds it with
      no extra interaction.

## 7. Build, validate, close out

- [x] 7.1 `openspec validate add-screenshot-annotation --strict`.
- [x] 7.2 Build the affected configurations. `pim-hyprland` reaches cichorei,
      doornappel and peterspav through `modules/ROLES/home-pim-desktop.nix:26`,
      and the package addition is NixOS-side, so both a system rebuild and a home
      switch are needed. This repo needs `--impure`: `pim-awscli-dir` reads
      `~/.aws/other_accounts.json`, which pure evaluation forbids.
- [x] 7.3 `git add` the new scripts before building. A flake build only sees
      tracked files, so an untracked script is silently omitted rather than
      erroring.
- [ ] 7.4 Set the bean
      `.beans/mipnix-i4oy--replace-hyprland-screenshot-with-grimslurpsatty.md`
      to `completed` on archive, and add the `openspec-link` to its frontmatter.
