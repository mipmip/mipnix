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

## 6. Signability & the `stale` state (post-plan: gcr listed but couldn't sign)

- [x] 6.1 Discovered gcr kept the key in `ssh-add -l` but hung on `ssh-add -T` (SSH stalled
      after "Server accepts key"); `ssh-add -d`/`-D`/re-add/agent-restart could not clear it.
- [x] 6.2 Add a `timeout`-bounded `ssh-add -T` to the poll; report listed-but-unsignable as a
      fourth state `stale`. Extend the poll script and `normalizeState` accordingly.
- [x] 6.3 Add the `stale` icon (lock-with-alert) and `.stale` (red) CSS class.

## 7. Popover UI & icon polarity (post-plan: no-op click read as broken)

- [x] 7.1 Replace the bare click handler with a `menubutton` popover that names the state and
      offers Load (unloaded/stale) / Unload (loaded) / nothing (no-agent); show the
      fingerprint when loaded.
- [x] 7.2 Switch state from `createPoll` to `createState` + a `refresh()` driven by
      `interval`, re-polled immediately after Load/Unload (on success and failure).
- [x] 7.3 Add an `inFlight` guard so each activation fires at most one `ssh-add` / one popup.
- [x] 7.4 Swap the loaded/unloaded glyphs: open padlock = loaded (unlocked/available),
      closed padlock = unloaded (locked away).

## 8. askpass scoping & floating (post-plan: popup fired for all ssh; tiled)

- [x] 8.1 Inject the standalone askpass path into the bundle at build time: `ASKPASS`
      `ags bundle -d` define in `flake.nix`, declared in `env.d.ts`; use it inline in the
      widget's Load command.
- [x] 8.2 Remove the session-wide `SSH_ASKPASS` / `SSH_ASKPASS_REQUIRE` from
      `home.sessionVariables` (they forced the GUI for *all* terminal ssh); set them inline
      on the widget's `ssh-add` instead, with `< /dev/null` so it can't fall back to a tty.
- [x] 8.3 Float/center the askpass window via a Hyprland window rule. It reports an empty
      class, so match on its title; use the 0.53+ syntax
      `windowrule = match:title ^(OpenSSH Authentication Passphrase request)$, float on, center on`.

## 9. Plain ssh-agent bypass (post-plan: root-cause fix for the `stale` hang)

- [x] 9.1 Enable `services.ssh-agent` (plain OpenSSH agent) in the mipbar module.
- [x] 9.2 Point the graphical session at it via
      `systemd.user.sessionVariables.SSH_AUTH_SOCK = "%t/ssh-agent"` and a Hyprland
      `env = SSH_AUTH_SOCK,$XDG_RUNTIME_DIR/ssh-agent` line.
- [x] 9.3 Mask gcr's ssh-agent socket + service via
      `xdg.configFile."systemd/user/gcr-ssh-agent.{socket,service}".source =
      config.lib.file.mkOutOfStoreSymlink "/dev/null"` (a plain `/dev/null` source fails HM
      with "unsupported type").
- [x] 9.4 Keep gnome-keyring for the Secret Service (Signal/granted-aws/libsecret); confirm
      only the SSH role is dropped.

## 10. Live verification (needs the running session)

- [x] 10.1 After rebuild + fresh login: `SSH_AUTH_SOCK` points at the plain agent, gcr
      ssh-agent masked, agent starts empty → indicator shows `unloaded`. (Confirmed live.)
- [x] 10.2 Terminal `ssh <host>` prompts on the tty (not the GUI popup); widget Load shows
      the GUI popup, floated. (Confirmed live after the askpass-scoping fix.)
- [x] 10.3 Load → passphrase prompt → key signs → indicator flips to `loaded` and
      `ssh pim@lavendel` works. (Confirmed live.)
- [ ] 10.4 Re-verify the `stale` state no longer occurs in normal use with the plain agent
      (it was a gcr artifact); keep the `stale` branch as a safety net. (Monitor over
      normal sessions.)
