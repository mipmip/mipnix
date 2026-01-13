# Implementation Tasks

## Phase 1: Migration to flake-parts structure

### 1. Preparation
- [x] 1.1 Review current module structure and imports
- [x] 1.2 Identify all files to be migrated (39 modules identified)
- [x] 1.3 Verify no active work in progress on these modules

### 2. Module Migration (Incremental, per file)
- [x] 2.1 Create new files in `modules/users/pim/<category>/<name>.nix` with flake-parts structure
- [x] 2.2 Add each `pim-<name>` to imports list in `modules/users/pim/home-manager.nix`
- [x] 2.3 Rename old files to `<name>.nix.moved` to prevent auto-import
- [x] 2.4 Stage new/modified files in git after each migration
- [x] 2.5 Test build after each module migration
- [x] 2.6 Complete all 39 modules:
  - [x] Simple modules (git, direnv, fzf, atuin, shellstuff, alacritty, kitty, ghostty, obs, awscli, aider, dirtygit, nix, npm, wtf, gimp, myhotkeys, thunderbird, bmc, awscli-dir, smug-skull, freedesktop, pandoc, sc-im)
  - [x] Complex modules with subdirectories (fish, zsh, vim, tmux, neovim, hyprland, firefox, librewolf, wrofi)
  - [x] Final modules (gnome, fonts, shared)

### 3. Testing After Full Migration
- [x] 3.1 Run `nix flake check` to verify no syntax errors
- [x] 3.2 Test full build: `nix build .#homeConfigurations."pim@lego2".activationPackage`
- [x] 3.3 Verify all program modules load correctly and no missing imports

### 4. Cleanup
- [x] 4.1 Remove old `home/pim/_hm-modules/` directory entirely
- [x] 4.2 Commit changes with descriptive message

## Phase 2: Remove self-referential options/mkIf patterns

### 5. Options/mkIf Pattern Analysis
- [x] 5.1 Identify all modules with self-referential enable options (19 modules)
- [x] 5.2 Identify cross-module options to preserve (shared.shellAliases, desktopConf.gnome.swapAltWin)
- [x] 5.3 Identify cross-module mkIf conditions to preserve (config.roles.secondbrain.enable)
- [x] 5.4 Plan fish/zsh shell-aliases import strategy

### 6. Remove Options/mkIf from Modules
- [x] 6.1 Update fish and zsh to import shell-aliases module directly
- [x] 6.2 Remove self-referential options from simple desktop programs (alacritty, kitty, ghostty, obs, firefox, librewolf)
- [x] 6.3 Remove options/mkIf from complex modules (smug_n_skull, freedesktop, awscli-dir, gimp, myhotkeys)
- [x] 6.4 Remove options/mkIf from fonts module
- [x] 6.5 Clean up GNOME modules while preserving swapAltWin option (desktop-generic, desktop-input-sources, desktop-shortcuts, gnome-extensions)
- [x] 6.6 Remove shell-aliases from root imports in home-manager.nix

### 7. Final Testing
- [x] 7.1 Test build after all options/mkIf removed
- [x] 7.2 Verify no self-referential options remain
- [x] 7.3 Verify cross-module options still work

### 8. Documentation
- [x] 8.1 Update project.md with lessons learned
- [x] 8.2 Update OpenSpec change documentation to reflect both phases
- [x] 8.3 Archive the OpenSpec change
