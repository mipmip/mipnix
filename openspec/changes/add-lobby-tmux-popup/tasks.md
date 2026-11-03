## 1. Registry

- [x] 1.1 Add `browse` (bool, default true) to `lobby.services` in `modules/lobby/option.nix` and export it in the JSON
- [x] 1.2 Set `browse = false` for prometheus, tuwunel and linny-mcp

## 2. lobby command

- [x] 2.1 Filter the picker on `url != null and browse`
- [x] 2.2 Start the browser with `setsid -f xdg-open` in `open_url`
- [x] 2.3 Check that `lobby list` still shows all services and that the picker list leaves out samba, prometheus, tuwunel and linny-mcp

## 3. tmux

- [x] 3.1 Add the `W` entry to `modules/USERS/pim/programs/tmux/binds.nix`
- [x] 3.2 Build the home configuration and check that `prefix + W` is bound in the generated tmux config

## 4. Rollout

- [ ] 4.1 Commit and `rme up_home` on delliebellie
- [ ] 4.2 User: `prefix + W`, pick a service, browser opens, popup closes
- [ ] 4.3 User: `prefix + W`, Escape, popup closes
