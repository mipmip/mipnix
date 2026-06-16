## 1. Remove the flake inputs

- [x] 1.1 Removed the `walker = { ... }` input block from `flake.nix`.
- [x] 1.2 Removed the `elephant.url = ...` input from `flake.nix`.
- [x] 1.3 `flake.lock` updates on the next build (walker/elephant nodes + their private nixpkgs drop out); build succeeded with no references to them.

## 2. Switch to official package + home-manager module

- [x] 2.1 Removed `imports = [ inputs.walker.homeManagerModules.default ]` from `default.nix`.
- [x] 2.2 Replaced `programs.walker { runAsService = true; }` with `services.walker = { enable = true; systemd.enable = true; }` (the official `release-26.05` HM module; package defaults to `pkgs.walker`).
- [x] 2.3 Deleted the `programs.elephant { providers; settings; }` block (golden-path defaults).
- [x] 2.4 `home.packages = [ pkgs.elephant ]` (dropped `inputs.walker.packages...`; walker comes via `services.walker`). `inputs` arg now unused but harmless.

## 3. Clean up redundant cruft

- [x] 3.1 REVISED after live test: `services.walker.systemd.enable` was set false (its systemd unit is `WantedBy graphical-session.target`, which this non-uwsm Hyprland session leaves `inactive` → service never auto-starts). So `exec-once = walker --gapplication-service` was RESTORED in `autostart.conf` as the launch trigger. `exec-once = elephant` kept.
- [x] 3.2 Removed the `walker.cachix.org` substituter + key from `modules/nix/cli.nix` (the now-empty `settings` block was removed).

## 4. Build and verify

- [x] 4.1 Built `pim@lego2` home config (`--impure`, exit 0). Verified: `walker` → `walker-2.16.2` and `elephant` → `elephant-2.21.0` from nixpkgs (cache.nixos.org), no flake-input refs remain, cachix removed. After the systemd→autostart fix (3.1), NO `walker.service` is generated.
- [x] 4.2 Tested the systemd-service approach live: `graphical-session.target` is `inactive` under this Hyprland session (no uwsm/systemd integration), so `walker.service` stayed `enabled` but `inactive (dead)`. Switched to `systemd.enable = false` + `exec-once` autostart; rebuild confirms no `walker.service`.
- [x] 4.3 Deploy and open the launcher (mipbar button + `SPACE`) — confirm Walker appears and returns results (Elephant backend working, not an empty launcher).
- [x] 4.4 Resolved: `exec-once = elephant` kept (Elephant is Walker's backend daemon; this session has no systemd integration to start it otherwise).
