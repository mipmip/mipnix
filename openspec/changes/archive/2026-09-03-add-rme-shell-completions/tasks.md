## 1. Fish completions

- [x] 1.1 In `modules/USERS/pim/programs/fish/default.nix`, add
      `xdg.configFile."fish/completions/rme.fish".text = "complete -c rme -f -a '(rme --completions)'";`

## 2. Zsh completions

- [x] 2.1 In `modules/USERS/pim/programs/zsh/default.nix`, append to
      `programs.zsh.initContent`:
      `_rme() { compadd $(rme --completions) }` and `compdef _rme rme`

## 3. Verification

- [x] 3.1 Nix syntax-check both edited files (`nix-instantiate --parse`) — both OK
- [x] 3.2 CONFIRMED: `~/.config/fish/completions/rme.fish` exists (HM symlink) with
      `complete -c rme -f -a '(rme --completions)'`
- [x] 3.3 CONFIRMED: `fish -c 'complete -C "rme "'` returns real commands (deploy_remote,
      nebula_hosts, new_host, …) from `rme --completions`
- [x] 3.4 CONFIRMED: in zsh `_rme` is a defined function and `compdef _rme rme` is wired
- [x] 3.5 By design: the completion calls `rme --completions`, which returns nothing in a
      directory without a `RUNME.sh` → no suggestions, no error (dynamic, no static list)
