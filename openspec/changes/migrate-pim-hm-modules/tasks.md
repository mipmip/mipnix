# Implementation Tasks

## 1. Preparation
- [x] 1.1 Review current module structure and imports
- [x] 1.2 Identify all files to be migrated
- [x] 1.3 Verify no active work in progress on these modules

## 2. Directory Migration
- [ ] 2.1 Create `modules/users/pim/hm-modules/` directory structure
- [ ] 2.2 Copy all `.nix` files from `home/pim/_hm-modules/` subdirectories to `modules/users/pim/hm-modules/` (flatten or preserve structure)
- [ ] 2.3 Delete `home/pim/_hm-modules/default.nix` (replaced by auto-import pattern)
- [ ] 2.4 Verify all files copied correctly with checksums or diff

## 3. Testing
- [ ] 4.1 Run `nix flake check` to verify no syntax errors
- [ ] 4.2 Test build Home Manager configuration: `home-manager build --flake .#pim@passieflora`
- [ ] 4.3 Test on at least one other host configuration (e.g., `pim@harry`)
- [ ] 4.4 Verify all program modules load correctly and no missing imports

## 4. Cleanup
- [ ] 5.1 After successful testing, remove old `home/pim/_hm-modules/` directory
- [ ] 5.2 Commit changes with descriptive message
- [ ] 5.3 Update documentation if needed (CLAUDE.md or project.md references)

## 5. Deployment
- [ ] 6.1 Deploy to one test machine (e.g., passieflora)
- [ ] 6.2 Verify desktop environment and programs work correctly
- [ ] 6.3 Roll out to remaining machines gradually
