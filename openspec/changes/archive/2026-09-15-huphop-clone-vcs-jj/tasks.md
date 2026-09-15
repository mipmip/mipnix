## 1. Implementation

- [x] 1.1 In `modules/USERS/pim/programs/huphop/default.nix`, add `clone_vcs = "jj";`
      to the `hupConfig` attrset, next to `search_strategy`, with a short comment
      noting that it means `jj git clone --colocate` and that a real `.git` remains.
- [x] 1.2 Leave `hup-tmux-switch` untouched, because the clone engine runs before
      `switch_command`, so the tmux wiring needs no change.

## 2. Verification

- [x] 2.1 `nix build .#homeConfigurations...` (or the usual `nixos-rebuild switch` for
      this host) succeeds and `~/.config/huphop/config.yaml` contains `clone_vcs: jj`.
- [x] 2.2 `hup config check` reports the configuration valid.
- [ ] 2.3 Clone one repository that is not yet present (via `prefix + G`, pick an
      uncloned repo) and confirm the checkout has both `.jj/` and `.git/`, the switch
      into the tmux window still works, and the fish prompt shows jj info.
      NOT RUN: needs an interactive tmux popup and a real network clone into `~`.
      Left for the first real switch after the rebuild. `jj` is on PATH (0.41.0),
      which is huphop's only prerequisite for the jj clone path.
