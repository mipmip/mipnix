# Tasks

Schema source: https://github.com/speclib/openspec-tinychange-schema

## 1. Implementation

- [x] 1.1 In `secrets/secrets.nix`, widen `"ghi-token.age".publicKeys` from `users` to `users ++ personal_laptops` and drop the stale `## should configure ghi in home manager` note
- [x] 1.2 Re-encrypt `secrets/ghi-token.age` to the new recipient set with `./RUNME.sh rekey`. Audited every `.age` file against HEAD: only `ghi-token.age` changed recipients, gaining `cichorei`, `doornappel` and `peterspav` while keeping `pim` and `annemarie`
- [x] 1.3 Add `modules/nix/github-token.nix` exposing `flake.modules.nixos.nix-github-token`: an `age.secrets.ghi-token` entry (root:root, 600), `nix.extraOptions` carrying `!include /etc/nix/access-tokens.conf`, and a `system.activationScripts.nixAccessTokens` with `deps = [ "agenix" ]` that renders both fragments with `install -m 600 -o <owner> -g <group>`
- [x] 1.4 Import `nix-github-token` in the NixOS module of `cichorei-laptop`, `doornappel-laptop` and `peterspav-laptop`
- [x] 1.5 Add `!include /home/pim/.config/nix/access-tokens.conf` to `nix.extraOptions` in `modules/USERS/pim/programs/nix.nix`

## 2. Verification

- [x] 2.1 `system.build.toplevel.drvPath` evaluates for all three laptops; `pim@<host>` activationPackage evaluates with `--impure` (the home config reads `/home/pim/.aws/other_accounts.json`, a pre-existing impurity). Resolved `nix.extraOptions` carries `!include /etc/nix/access-tokens.conf` at system level and `!include /home/pim/.config/nix/access-tokens.conf` for pim
- [x] 2.2 The rendered activation script references `/run/agenix/ghi-token` and contains no token literal; the store nix.conf holds only the `!include` line. Ran the script body against a fake token in a scratch tree: fragments came out `600`, directories `755`, and `nix config show access-tokens` read the value back through the `!include`
- [ ] 2.3 After `nixos-rebuild switch`, `stat -c '%U %G %a'` reports `root root 600` for `/etc/nix/access-tokens.conf` and `pim users 600` for `~/.config/nix/access-tokens.conf`
- [ ] 2.4 `nix flake update nivis` succeeds as pim with no `--option access-tokens` on the command line
