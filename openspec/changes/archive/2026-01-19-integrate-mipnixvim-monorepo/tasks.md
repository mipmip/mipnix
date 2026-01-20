## 1. Add Nixvim as Direct Dependency
- [x] 1.1 Add `nixvim.url = "github:nix-community/nixvim"` to flake.nix inputs
- [x] 1.2 Add `nixvim.inputs.nixpkgs.follows = "unstable"` to use unstable nixpkgs
- [x] 1.3 Add `pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix"` to flake.nix inputs
- [x] 1.4 Add `pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs"` for consistency
- [x] 1.5 Remove `mipvim.url = "path:./packages/mipvim"` from flake.nix inputs
- [x] 1.6 Remove `mipvim.inputs.nixpkgs.follows = "unstable"` (no longer needed)
- [x] 1.7 Run `nix flake lock` to update flake.lock

**Validation**: Flake evaluates without errors, nixvim input added, mipvim input removed

## 2. Build Mipvim in Root Flake PerSystem
- [x] 2.1 Update perSystem in flake.nix to import unstable nixpkgs
- [x] 2.2 Create nixvimLib and nixvim' references from inputs.nixvim
- [x] 2.3 Define nixvimModule with pkgs-unstable and import-tree config loading
- [x] 2.4 Add `packages.mipvim` using `nixvim'.makeNixvimWithModule`
- [x] 2.5 Add `checks.mipvim` using `nixvimLib.check.mkTestDerivationFromNixvimModule`
- [x] 2.6 Test package availability: `nix eval .#packages.x86_64-linux --apply "x: builtins.hasAttr \"mipvim\" x"`
- [x] 2.7 Test dry-run build: `nix build .#mipvim --dry-run`

**Validation**: Package builds successfully, no version mismatch warnings

**Dependencies**: Must complete section 1 first

## 3. Clean Up Mipvim Package Directory
- [x] 3.1 Remove `packages/mipvim/flake.nix` (no longer needed)
- [x] 3.2 Remove `packages/mipvim/flake.lock` (no longer needed)
- [x] 3.3 Remove `packages/mipvim/.gitignore` (no longer needed)
- [x] 3.4 Remove `packages/mipvim/.envrc` (no longer needed)
- [x] 3.5 Remove `packages/mipvim/README.md` (no longer needed)
- [x] 3.6 Remove `packages/mipvim/.direnv/` directory
- [x] 3.7 Remove `packages/mipvim/.pre-commit-config.yaml` symlink
- [x] 3.8 Keep `packages/mipvim/config/` and `packages/mipvim/configDisabled/` directories

**Validation**: Only config directories remain in packages/mipvim/

**Dependencies**: Can run in parallel with section 2

## 4. Fix Nixvim Configuration Deprecations
- [x] 4.1 Update `packages/mipvim/config/plugins/editor/treesitter.nix`: change `folding = false` to `folding.enable = false`
- [x] 4.2 Update `packages/mipvim/config/plugins/editor/neo-tree.nix`: move all top-level options to `settings.*` structure
- [x] 4.3 Update `packages/mipvim/config/plugins/editor/neo-tree.nix`: move `window.mappings` to `settings.window.mappings`
- [x] 4.4 Update neo-tree: change camelCase options to snake_case (e.g., `bindToCwd` → `bind_to_cwd`)
- [x] 4.5 Test build to verify deprecation warnings are resolved: `nix build .#mipvim --dry-run 2>&1 | grep -E "treesitter.folding|neo-tree.window.mappings"`

**Validation**: No errors for treesitter.folding or neo-tree.window.mappings (remaining warnings are acceptable)

**Dependencies**: Must complete section 2 first

## 5. Update Module References
- [x] 5.1 Update `modules/users/pim/programs/neovim/default.nix`: remove `mipvim` from function parameters
- [x] 5.2 Update `modules/users/pim/programs/neovim/default.nix`: change `mipvim.packages."${system}".default` to `inputs.self.packages."${system}".mipvim`
- [x] 5.3 Update `modules/nix/helpers.nix`: remove `inherit (inputs) mipvim;` from extraSpecialArgs
- [x] 5.4 Search codebase for any other mipvim references: `rg "mipvim" modules/ --type nix`

**Validation**: No remaining references to `inputs.mipvim` or `mipvim.packages` in active code

**Dependencies**: Must complete section 2 first

## 6. Integration Testing
- [x] 6.1 Verify no version mismatch warnings: `nix build .#mipvim --dry-run 2>&1 | grep -i "version\|mismatch"`
- [x] 6.2 Test package build: `nix build .#mipvim --dry-run`
- [x] 6.3 Verify package is exposed: `nix eval .#packages.x86_64-linux.mipvim.name 2>&1`
- [ ] 6.4 Test Home Manager rebuild: `./RUNME.sh up_home` (or equivalent)
- [ ] 6.5 Launch neovim and verify it works: `nvim --version` and basic editing
- [ ] 6.6 Verify all plugins load correctly in neovim

**Validation**: All builds succeed, neovim functions normally, no version warnings

**Dependencies**: Must complete sections 2-5

## 7. Documentation and Finalization
- [ ] 7.1 Update OpenSpec change documentation to reflect actual implementation
- [ ] 7.2 Update `openspec/project.md` if needed to reflect mipvim integration
- [ ] 7.3 Commit changes with descriptive message
- [ ] 7.4 Remove unused `modules/packages/mipvim.nix` if it exists (attempted module approach)

**Validation**: Documentation accurately describes the integration, changes committed

**Dependencies**: Should complete section 6 first
