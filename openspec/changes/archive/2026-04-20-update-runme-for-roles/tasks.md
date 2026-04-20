## 1. Fix directory paths

- [x] 1.1 Update `next_free_nebula_ip` to scan `modules/HOSTS/*/networking.nix` instead of `modules/hosts/*/networking.nix`
- [x] 1.2 Update `show_nebula_ip_allocation` to iterate over `modules/HOSTS/*/networking.nix`
- [x] 1.3 Update `new_host` HOST_DIR to use `modules/HOSTS/` instead of `modules/hosts/`

## 2. Add role selection

- [x] 2.1 Add role auto-discovery: scan `modules/ROLES/*.nix` for files containing `role-` prefixed module names
- [x] 2.2 Add `gum choose --no-limit` multi-select for discovered roles
- [x] 2.3 Include selected roles in the confirmation summary display

## 3. Update generated configuration.nix template

- [x] 3.1 Replace individual module imports (`system-locale`, `hm-nixos`, `nix-cli`, `user-pim`) with `system-default` as the single base import
- [x] 3.2 Add selected roles to the imports block in the generated configuration.nix
- [x] 3.3 Update the generated homeConfigurations to match the pattern used in existing hosts (e.g., lego2-laptop)

## 4. Replace nebula prompt with role-based trigger

- [x] 4.1 Remove the standalone `gum confirm "Set up nebula for this host?"` prompt
- [x] 4.2 Add logic to call `new_nebula_node` if `role-nebula-node` is in the selected roles
