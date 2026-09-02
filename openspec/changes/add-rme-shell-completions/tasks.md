## 1. Fish completions

- [x] 1.1 In `modules/USERS/pim/programs/fish/default.nix`, add
      `xdg.configFile."fish/completions/rme.fish".text = "complete -c rme -f -a '(rme --completions)'";`

## 2. Zsh completions

- [x] 2.1 In `modules/USERS/pim/programs/zsh/default.nix`, append to
      `programs.zsh.initContent`:
      `_rme() { compadd $(rme --completions) }` and `compdef _rme rme`

## 3. Verification

- [x] 3.1 Nix syntax-check both edited files (`nix-instantiate --parse`) — both OK
- [ ] 3.2 Post-switch: confirm `~/.config/fish/completions/rme.fish` exists with the dynamic line
- [ ] 3.3 Post-switch: in fish, in a directory with a `RUNME.sh`, `rme <Tab>` offers commands
      from `rme --completions` (no restart needed)
- [ ] 3.4 Post-switch: in a new zsh session, `rme <Tab>` offers commands in a `RUNME.sh` directory
- [ ] 3.5 Confirm a directory without a `RUNME.sh` yields no suggestions and no error
