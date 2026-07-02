## 1. SshKey widget

- [x] 1.1 Add `packages/mipbar/widget/SshKey.tsx`, modeled on `Camera.tsx`: a
      `createPoll("", 5000, ["bash","-c", …])` that emits one of `loaded` / `unloaded` /
      `noagent`.
- [x] 1.2 Poll script: derive the fingerprint via
      `fp=$(ssh-keygen -lf ~/.ssh/id_ed25519.pub | awk '{print $2}')`, capture
      `out=$(ssh-add -l)` and its exit code; emit `noagent` on exit 2, `loaded` if `out`
      contains `$fp`, else `unloaded`.
- [x] 1.3 Render an always-visible `<box class="StatusIcon SshKey {state}">` with a
      `<button>`; bind icon and the `.loaded`/`.unloaded`/`.noagent` class to the polled
      state. Set `tooltipText` per state (e.g. fingerprint when loaded, "click to load"
      when unloaded, "ssh-agent unreachable" when no-agent).
- [x] 1.4 Click handler: when state is `unloaded`, `execAsync` `ssh-add ~/.ssh/id_ed25519`
      (with `SSH_ASKPASS_REQUIRE=force` and inherited `SSH_AUTH_SOCK` as needed); no-op for
      `loaded` / `noagent`. Optionally force a re-poll after the load resolves.

## 2. Bar integration & styling

- [x] 2.1 `Bar.tsx`: import `SshKey` and add `<SshKey />` to the `end` `<box>` (alongside
      Camera/Screenshare/SystemMonitor).
- [x] 2.2 `style.scss`: add `.SshKey` with `.loaded` (green), `.unloaded` (amber),
      `.noagent` (grey) color cues, matching the existing `StatusIcon` styling.

## 3. Nix / dependencies

- [x] 3.1 Verify `ssh-keygen` and `ssh-add` are on the bar's PATH; if not, add
      `pkgs.openssh` to `home.packages` in
      `modules/USERS/pim/programs/mipbar/default.nix`.
      → Verified: both live at `/run/current-system/sw/bin/` (systemwide), so no
      `pkgs.openssh` needed. The mipbar module was instead extended with a
      standalone askpass (see 4.2).

## 4. askpass spike (de-risk before finalizing click behavior)

- [x] 4.1 Confirm that `ssh-add ~/.ssh/id_ed25519` invoked from the detached mipbar process
      routes the passphrase prompt to gcr's GUI pinentry (test the `execAsync` env).
      → Result: it does NOT route via gcr. `SSH_ASKPASS_REQUIRE=force` alone gives
      `ssh_askpass: exec(): No such file or directory` (no askpass on PATH); pointing
      `SSH_ASKPASS` at either gcr helper (v3 `gcr-ssh-askpass` or v4 `gcr4-ssh-askpass`)
      gives `this program is not meant to be run directly` — gcr's askpass only works
      when driven by gcr's own prompter, not as a generic `SSH_ASKPASS`. Also noted:
      the gcr agent refuses `ssh-add -d` ("agent refused operation").
- [x] 4.2 If it does not route cleanly, choose a fallback: trigger a dummy ssh connection
      (gcr auto-load) or drop click-to-load and make the widget informational; update the
      spec/design accordingly.
      → Decision (user-chosen): keep `ssh-add` click-to-load and wire a standalone
      askpass. Added `pkgs.lxqt.lxqt-openssh-askpass` to the mipbar module's
      `home.packages` and set `SSH_ASKPASS` (to it) + `SSH_ASKPASS_REQUIRE=force` via
      `home.sessionVariables`. Verified the askpass path is valid/executable and
      `ssh-add` no longer errors on exec.

## 5. Verification

- [x] 5.1 With the key loaded: confirm the indicator shows the "loaded" icon/color and the
      tooltip shows the fingerprint.
      → Poll logic verified: real agent → `loaded`; tooltip fingerprint resolves to
      `SHA256:99MlTK/…RRVM`. Live icon/colour needs the running bar (see note below).
- [x] 5.2 Remove the key (`ssh-add -d ~/.ssh/id_ed25519`): confirm the indicator flips to
      "unloaded" within one poll interval.
      → Note: the gcr agent REFUSES `ssh-add -d` ("agent refused operation"), so this
      exact removal method is unavailable on this setup. Verified the `unloaded`
      branch instead by feeding the poll script an agent listing whose fingerprint
      differs from the file's → correctly emits `unloaded`.
- [ ] 5.3 From "unloaded", click the indicator: confirm the passphrase prompt appears, the
      key loads, and the indicator returns to "loaded".
      → REQUIRES LIVE BAR + interactive GUI: cannot exercise a real passphrase prompt
      non-interactively (and gcr won't let us reach an unloaded state to click from).
      Askpass routing groundwork verified in 4.2. User to confirm after rebuild.
- [x] 5.4 Simulate no agent (unset/break `SSH_AUTH_SOCK`): confirm the "no-agent" state.
      → Verified: `SSH_AUTH_SOCK=/nonexistent` → `ssh-add -l` rc=2 → script emits
      `noagent`.
- [x] 5.5 Confirm the comment mismatch (file `post@pimsnel.com` vs agent `pim@ojs`) does not
      prevent a "loaded" match.
      → Verified: a listing with comment `pim@ojs` but the file's fingerprint still
      matches (grep is on the fingerprint, not the comment) → `loaded`.
