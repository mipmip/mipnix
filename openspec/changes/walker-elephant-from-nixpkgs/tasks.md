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

- [x] 3.1 Removed `exec-once = walker --gapplication-service` from `autostart.conf` (the systemd user service runs it). Kept `exec-once = elephant` pending the daemon-ordering check (4.4).
- [x] 3.2 Removed the `walker.cachix.org` substituter + key from `modules/nix/cli.nix` (the now-empty `settings` block was removed).

## 4. Build and verify

- [x] 4.1 Built `pim@lego2` home config (`--impure`, exit 0). Verified: `walker` → `walker-2.16.2` and `elephant` → `elephant-2.21.0` from nixpkgs (pulled from cache.nixos.org), `walker.service` systemd unit generated, no flake-input refs remain, cachix removed.
- [ ] 4.2 Deploy; confirm the `walker` systemd user service is active
- [ ] 4.3 Open the launcher (mipbar button + `SPACE` keybind) and confirm it returns results (Elephant backend working, not an empty launcher)
- [ ] 4.4 Resolve the open question: confirm whether `exec-once = elephant` must remain in autostart, or whether `services.walker` starts elephant itself — keep/remove the elephant autostart line accordingly
