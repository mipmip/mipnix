## 1. Launcher

- [x] 1.1 Run the picker's window command with `-t` and
  `env NEBULA_TMUX=1 "$SHELL" -l`, and verify the generated script leaves
  `$SHELL` for the remote side to expand

## 2. Tmux configuration

- [x] 2.1 Add `if-shell '[ -n "$NEBULA_TMUX" ]' 'set -g prefix2 C-s'` to the
  shared configuration and verify on a scratch socket that a server started
  with the variable reports `prefix2 C-s`, while one started without it reports
  the default
- [x] 2.2 Show the second prefix in the status bar by setting `@prefix_extra`
  alongside `prefix2` and appending a conditional to the status-right, then
  verify on a scratch socket that a marker server shows `C-a` and `C-s` while a
  plain server shows only `C-a`
- [x] 2.3 Use `👻` as the status-bar marker on a marker server and keep `🤠`
  elsewhere, then verify both on a scratch socket

## 3. Validation

- [x] 3.1 Run `openspec validate add-nebula-popup-prefix --strict` and verify
  the change passes

## 4. Deployment

- [ ] 4.1 Deploy to `peterspav`, restart its tmux server, open the popup, run
  `t`, and verify `tmux show -g prefix2` reports `C-s` while `prefix` still
  reports `C-a`
- [ ] 4.2 Deploy to the remaining nebula hosts and verify the same on one of
  them
- [x] 4.3 Verify that a direct ssh shell or a console session does not gain
  `C-s` as `prefix2`
- [x] 4.4 Verify that a server left running from before the deploy keeps its
  old prefixes until it is restarted
- [x] 4.5 Deploy the status-bar change to the test host and verify that a marker
  server shows both prefixes while a plain server shows only the primary one
