## 1. jj config aliases

- [x] 1.1 In `modules/USERS/pim/programs/jj.nix`, add to `programs.jujutsu.settings` a
      `revset-aliases` entry `"closest_bookmark(to)" = "heads(::to & bookmarks())"`
- [x] 1.2 Add an `aliases` entry `tug = ["bookmark" "move" "--from" "closest_bookmark(@-)" "--to" "@-"]`

## 2. fish abbreviations

- [x] 2.1 In `modules/USERS/pim/programs/fish/default.nix`, add abbreviation `jp` expanding
      to `jj tug && jj git push`
- [x] 2.2 Add abbreviation `jc` expanding to `jj commit -m` (with cursor positioned for the message)

## 3. Verification

- [x] 3.1 Nix syntax-check both edited files (`nix-instantiate --parse`) — both OK. Full
      home-manager rebuild deferred to `nixos-rebuild switch`.
- [ ] 3.2 In a jj repo (post-rebuild): run `jj tug` and confirm the closest bookmark advances to `@-`
- [ ] 3.3 In fish (post-rebuild): type `jp` and confirm it expands to `jj tug && jj git push`
- [ ] 3.4 In fish (post-rebuild): type `jc` and confirm it expands to `jj commit -m "…"`
- [x] 3.5 Confirm no `describe && new` chain exists anywhere in the config — verified via rg
