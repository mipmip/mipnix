## Why

The RUNME.sh `new_host` and `new_nebula_node` commands reference the old directory structure (`modules/hosts/`) but the repo has been refactored to use `modules/HOSTS/`. The `new_host` template also generates configuration.nix with individual module imports (`system-locale`, `hm-nixos`, `nix-cli`, `user-pim`) instead of using the new ROLES system (`system-default`, `role-devbox`, `role-desktop-pim`, `role-nebula-node`, `role-server`). This makes scaffolded hosts inconsistent with the actual codebase conventions.

## What Changes

- Fix all path references from `modules/hosts/` to `modules/HOSTS/` in `next_free_nebula_ip`, `show_nebula_ip_allocation`, and `new_host`
- Update `new_host` generated `configuration.nix` template to use `system-default` role (which already bundles locale, hm-nixos, nix-cli, user-pim, etc.) instead of listing individual modules
- Add interactive role selection to `new_host` using `gum choose --no-limit` so users can pick from available roles (`role-devbox`, `role-desktop-pim`, `role-nebula-node`, `role-server`)
- Update the generated imports to include selected roles
- Remove the separate "optional nebula setup" prompt — nebula is now handled by selecting the `role-nebula-node` role, which triggers `new_nebula_node` automatically

## Capabilities

### New Capabilities
- `runme-role-selection`: Interactive role selection during host scaffolding, with auto-detection of available roles from `modules/ROLES/` and conditional nebula cert generation when `role-nebula-node` is selected

### Modified Capabilities
- `host-scaffolding`: Update directory paths and generated templates to match refactored structure and roles pattern

## Impact

- `RUNME.sh`: Modified functions: `new_host`, `next_free_nebula_ip`, `show_nebula_ip_allocation`
- Generated host files will match the pattern used by existing hosts like `lego2-laptop`
