## 1. Launcher

- [x] 1.1 Run the picker's window command with `-t` and
  `env NEBULA_TMUX=1 "$SHELL" -l`, and verify the generated script leaves
  `$SHELL` for the remote side to expand

## 2. Tmux configuration

- [x] 2.1 Add `if-shell '[ -n "$NEBULA_TMUX" ]' 'set -g prefix2 C-s'` to the
  shared configuration and verify on a scratch socket that a server started
  with the variable reports `prefix2 C-s`, while one started without it reports
  the default

## 3. Validation

- [x] 3.1 Run `openspec validate add-nebula-popup-prefix --strict` and verify
  the change passes

## 4. Deployment

- [ ] 4.1 Deploy to `peterspav`, restart its tmux server, open the popup, run
  `t`, and verify `tmux show -g prefix2` reports `C-s` while `prefix` still
  reports `C-a`
- [ ] 4.2 Deploy to the remaining nebula hosts and verify the same on one of
  them
- [ ] 4.3 Verify that a direct ssh shell or a console session does not gain
  `C-s` as `prefix2`
- [ ] 4.4 Verify that a server left running from before the deploy keeps its
  old prefixes until it is restarted
