## 1. drs-switch wrapper

- [x] 1.1 In `modules/USERS/pim/programs/tmux/default.nix`, add a `drs-switch`
      `pkgs.writeShellScriptBin` (modeled on `nebula-ssh`) that: takes a repo dir as `$1`,
      computes `name=$(basename "$dir")`, and does create-or-select into the `dirtyrepos`
      session — `has-session -t "=dirtyrepos"` → `new-session -d -s dirtyrepos -n "$name" -c "$dir"`;
      else window check via `list-windows -F '#W' | grep -qx "$name"` → `new-window -d -t "=dirtyrepos" -n "$name" -c "$dir"`;
      then `switch-client -t "=dirtyrepos:$name"`
- [x] 1.2 Add `drs-switch` to `home.packages`

## 2. drs config

- [x] 2.1 In `modules/USERS/pim/programs/dirty-repo-scanner/config.yml`, add
      `switch_command: drs-switch %WORKING_DIRECTORY`

## 3. tmux binding

- [x] 3.1 In `modules/USERS/pim/programs/tmux/default.nix` `extraConfig`, add
      `bind R popup -E -w 80% -h 80% 'drs --multiplex'`

## 4. Verification

- [x] 4.1 Nix syntax-check both edited files (`nix-instantiate --parse`) — both OK (tmux
      via nix-instantiate, config.yml via yaml.safe_load). Full rebuild deferred to switch.
- [ ] 4.2 Post-rebuild: `prefix + R` opens a popup running `drs --multiplex`
- [ ] 4.3 Post-rebuild: selecting a repo creates the `dirtyrepos` session + a window named
      after the repo basename, started in the repo dir, and focuses it
- [ ] 4.4 Post-rebuild: selecting a second repo adds a second window (session not duplicated);
      re-selecting the first repo reuses its window (no duplicate)
