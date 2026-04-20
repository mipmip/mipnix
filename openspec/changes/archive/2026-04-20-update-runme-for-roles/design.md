## Context

RUNME.sh was written when the directory structure used `modules/hosts/` (lowercase) and hosts listed individual module imports. The repo has since been refactored: host directories live under `modules/HOSTS/` (uppercase) and composable roles under `modules/ROLES/` aggregate related modules (e.g., `role-desktop-pim` bundles all desktop modules, `role-devbox` bundles all dev tools). The `new_host` scaffolding command still generates the old pattern.

## Goals / Non-Goals

**Goals:**
- All path references in RUNME.sh match the actual `modules/HOSTS/` directory
- Generated `configuration.nix` uses `system-default` + selectable roles, matching existing hosts like `lego2-laptop`
- Role selection is interactive via `gum choose --no-limit` with roles auto-discovered from `modules/ROLES/`
- When `role-nebula-node` is selected, `new_nebula_node` is called automatically (replacing the separate nebula prompt)

**Non-Goals:**
- Changing the nebula cert generation logic itself
- Adding new roles
- Modifying existing host configurations to match the new template

## Decisions

### 1. Auto-discover roles from `modules/ROLES/`

Scan `modules/ROLES/*.nix` and extract the `role-*` names by stripping the path prefix. This means new roles added to the directory are automatically available in the selector without updating RUNME.sh.

**Alternative**: Hardcode a list of roles. Rejected because it creates maintenance burden and will drift.

### 2. Replace separate nebula prompt with role-based trigger

Currently `new_host` has a separate `gum confirm "Set up nebula for this host?"` after file creation. Instead, if the user selects `role-nebula-node` in the role selector, `new_nebula_node` runs automatically. This is more consistent — nebula is just another role, not a special case.

### 3. Simplify generated configuration.nix imports

The current template lists `system-default`, `system-locale`, `hm-nixos`, `nix-cli`, `user-pim` separately. Since `system-default` already includes all of these, the generated template should only import `system-default` plus selected roles. This matches how `lego2-laptop/configuration.nix` works.

### 4. Fix nebula IP scanning paths

`next_free_nebula_ip` and `show_nebula_ip_allocation` grep through `modules/hosts/*/networking.nix` — update to `modules/HOSTS/*/networking.nix`.

## Risks / Trade-offs

- **[Role discovery relies on filename convention]** → All role files in `modules/ROLES/` follow the `flake.modules.nixos.role-<name>` pattern. The auto-discovery strips the `.nix` extension and checks for `role-` prefix. If a file doesn't follow the convention (like `system-default.nix`), it won't appear in the role selector. This is intentional — `system-default` is always included, not optional.
- **[Nebula no longer separately prompted]** → Users who forget to select `role-nebula-node` won't get the nebula cert prompt. The success message will list available roles as a hint.
