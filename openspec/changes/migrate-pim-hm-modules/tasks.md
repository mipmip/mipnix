# Implementation Tasks

## 1. Preparation
- [x] 1.1 Review current module structure and imports
- [x] 1.2 Identify all files to be migrated
- [x] 1.3 Verify no active work in progress on these modules

## 2. Module Migration (Incremental, per file)

For each module in `home/pim/_hm-modules/<category>/*.nix`:

- [ ] 2.1 Create new file in `modules/users/pim/<category>/<name>.nix` with flake-parts structure:
  ```nix
  { inputs, ... }:
  {
    flake.modules.homeManager.pim-<name> = {
      # original module content here
    };
  }
  ```
- [ ] 2.2 Add `pim-<name>` to imports list in `modules/users/pim/home-manager.nix`
- [ ] 2.3 Rename old file to `<name>.nix.moved` to prevent auto-import
- [ ] 2.4 **CRITICAL**: Stage new/modified files in git:
  - `git add modules/users/pim/<category>/<name>.nix`
  - `git add modules/users/pim/home-manager.nix`
  - `git add home/pim/_hm-modules/<category>/<name>.nix.moved`
- [ ] 2.5 Test build: `nix build .#homeConfigurations."pim@lego2".activationPackage --dry-run`
- [ ] 2.6 Repeat for next module

**Migration Order**:
- Start with simple modules (direnv, git, fzf, atuin, etc.)
- Then tackle complex modules with subdirectories (fish, zsh, neovim, etc.)
- Finish with gnome, fonts, shared

## 3. Testing After Full Migration
- [ ] 3.1 Run `nix flake check` to verify no syntax errors
- [ ] 3.2 Test full build: `nix build .#homeConfigurations."pim@lego2".activationPackage`
- [ ] 3.3 Test on at least one other host configuration (e.g., `pim@harry`)
- [ ] 3.4 Verify all program modules load correctly and no missing imports

## 4. Cleanup
- [ ] 4.1 Remove old `home/pim/_hm-modules/` directory entirely
- [ ] 4.2 Remove `imports = [ ./_hm-modules ];` from `home/pim/default.nix` if empty
- [ ] 4.3 Commit changes with descriptive message
- [ ] 4.4 Update documentation if needed (CLAUDE.md or project.md references)

## 5. Deployment
- [ ] 5.1 Deploy to test machine lego2-laptop: `home-manager switch --flake .#pim@lego2`
- [ ] 5.2 Verify desktop environment and programs work correctly
- [ ] 5.3 Roll out to remaining machines gradually
