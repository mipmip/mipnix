## 1. Setup Package Directory Structure with Git History Preservation
- [ ] 1.1 Create `packages/` directory at repository root
- [ ] 1.2 Install git-filter-repo if not available: `nix-shell -p git-filter-repo`
- [ ] 1.3 Clone mipnixvim to temporary location: `git clone https://github.com/mipmip/mipnixvim /tmp/mipnixvim-temp`
- [ ] 1.4 Filter out bot contributors from history:
  ```bash
  cd /tmp/mipnixvim-temp
  git filter-repo --invert-paths --author-regex "renovate-bot|github-actions\[bot\]|renovate\[bot\]"
  ```
- [ ] 1.5 Add filtered repository as remote and merge with subtree:
  ```bash
  cd ~/nixos  # or your mipnix location
  git remote add mipnixvim-temp /tmp/mipnixvim-temp
  git fetch mipnixvim-temp
  git subtree add --prefix=packages/mipvim mipnixvim-temp main
  git remote remove mipnixvim-temp
  ```
- [ ] 1.6 Verify mipvim builds independently: `nix build ./packages/mipvim`
- [ ] 1.7 Clean up temporary clone: `rm -rf /tmp/mipnixvim-temp`

**Validation**: mipvim package builds successfully as standalone, git log shows mipnixvim history without bot commits

## 2. Update Flake Configuration
- [ ] 2.1 Remove `mipnixvim.url = "github:mipmip/mipnixvim";` from flake.nix inputs
- [ ] 2.2 Add mipvim package output in perSystem section
- [ ] 2.3 Run `nix flake lock` to update flake.lock without mipnixvim input
- [ ] 2.4 Test flake evaluation: `nix flake show`

**Validation**: Flake evaluates without errors and exposes `packages.${system}.mipvim`

**Dependencies**: Must complete section 1 first

## 3. Update Module References
- [ ] 3.1 Update `modules/users/pim/programs/neovim/default.nix`: change `mipnixvim.packages` to `inputs.self.packages` and reference `mipvim` (update parameter)
- [ ] 3.2 Check and update `modules/nix/helpers.nix` if it passes mipnixvim as specialArgs
- [ ] 3.3 Search codebase for any other mipnixvim references: `rg "inputs.*mipnixvim" modules/`
- [ ] 3.4 Stage all changed files: `git add modules/`

**Validation**: No remaining references to `inputs.mipnixvim` in active code

**Dependencies**: Must complete section 2 first

## 4. Update Development Tool Configurations
- [ ] 4.1 Update `modules/users/pim/programs/smug_n_skull/advanced_smugs.nix.data`: change name to "mipvim" and root path to `~/nixos/packages/mipvim` (or remove if redundant)
- [ ] 4.2 Update `modules/users/pim/programs/smug_n_skull/extra_skulls.nix.data`: change source to local path or remove github reference
- [ ] 4.3 Stage changed files: `git add modules/users/pim/programs/smug_n_skull/`

**Validation**: Skull/smug configurations reference correct paths

**Dependencies**: Can run in parallel with section 3

## 5. Update Documentation
- [ ] 5.1 Update `openspec/project.md`: Update tech stack and external dependencies sections to reflect monorepo integration and mipvim naming
- [ ] 5.2 Update `README.md` if it references mipnixvim as external dependency
- [ ] 5.3 Stage documentation: `git add openspec/project.md README.md`

**Validation**: Documentation accurately describes new structure and mipvim naming

**Dependencies**: Can run in parallel with sections 3-4

## 6. Integration Testing
- [ ] 6.1 Run full flake check: `nix flake check`
- [ ] 6.2 Test Home Manager rebuild: `./RUNME.sh up_home`
- [ ] 6.3 Launch neovim and verify it works: `nvim --version` and basic editing
- [ ] 6.4 Verify all plugins load correctly in neovim
- [ ] 6.5 Test on at least one other machine (if multi-machine setup)

**Validation**: All builds succeed, neovim functions normally

**Dependencies**: Must complete sections 2-5

## 7. Cleanup and Finalization
- [ ] 7.1 Remove old `~/mipnixvim` working directory if present (user decision)
- [ ] 7.2 Commit changes: `./RUNME.sh git_sync_machine "integrate mipnixvim into monorepo"`
- [ ] 7.3 Document decision about upstream GitHub repository (archive, mirror, or delete)

**Validation**: Changes committed and system fully operational

**Dependencies**: Must complete section 6
