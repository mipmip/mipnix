## Why

Walker (app launcher) and Elephant (its backend daemon) are now packaged in official
nixpkgs (26.05 ships `walker-2.16.2` and `elephant-2.21.0`), and home-manager 26.05 ships
an official `services.walker` module. They were originally consumed as upstream flake
inputs (`github:abenz1267/walker` + `/elephant`) only because they weren't packaged at the
time — each input also dragged in its own `nixpkgs`, bloating the lock.

Now that they're on the official "golden path", the custom flake inputs are unnecessary.
This migrates to the official package + home-manager module, accepting their defaults
(custom config can be re-added declaratively later if something is missed).

## What Changes

- Remove the `walker` and `elephant` flake inputs from `flake.nix` (and the extra nixpkgs
  trees they pull into the lock).
- Install Walker via the official home-manager `services.walker` module
  (`enable` + `systemd.enable`, package defaults to `pkgs.walker`).
- Install Elephant via the official package `pkgs.elephant` (home-manager 26.05 has no
  elephant module yet — golden path is the package with default config).
- Drop the bespoke `programs.elephant`/`programs.walker` configuration that came from the
  walker flake's home-manager module; start from defaults.
- Remove the now-redundant `exec-once = walker --gapplication-service` autostart line
  (the `services.walker` systemd user service runs it).
- Remove the `walker.cachix.org` binary cache + key from `modules/nix/cli.nix` (nixpkgs
  builds come from `cache.nixos.org`).

## Capabilities

### New Capabilities

- `walker-elephant-provisioning`: Walker and Elephant are provisioned from official
  nixpkgs/home-manager — Walker via the `services.walker` home-manager module (systemd
  user service), Elephant via the `pkgs.elephant` package — with no upstream/custom flake
  inputs. The `walker` and `elephant` commands remain available on PATH so existing
  launcher behavior (the mipbar button, `SPACE` keybind, etc.) is unaffected.

### Modified Capabilities

<!-- None. `app-launcher-button` is unchanged: clicking still calls `walker`, which still
     appears — this change only alters HOW walker/elephant are installed, not the button. -->


## Impact

- `flake.nix`: remove `walker` and `elephant` input blocks; lock drops walker, elephant,
  and their private nixpkgs/systems nodes.
- `modules/USERS/pim/programs/hyprland/default.nix`: remove the walker HM-module import,
  replace `programs.walker` with `services.walker { enable; systemd.enable; }`, remove the
  `programs.elephant` block, and add `pkgs.elephant` to `home.packages` (drop the
  `inputs.walker.packages...` reference).
- `modules/USERS/pim/programs/hyprland/hypr/autostart.conf`: drop the redundant walker
  service exec-once; verify Elephant launch/ordering still yields a working launcher.
- `modules/nix/cli.nix`: drop the `walker.cachix.org` substituter + trusted key.
- Runtime references (binds.conf, ashell, mipbar) need no change — they invoke `walker`/
  `elephant` on PATH, which the package provides.
- Trade-off: custom Elephant providers/settings (e.g. `desktopapplications.launch_prefix
  = "uwsm app --"`) are dropped in favor of defaults; re-add declaratively later if needed.
