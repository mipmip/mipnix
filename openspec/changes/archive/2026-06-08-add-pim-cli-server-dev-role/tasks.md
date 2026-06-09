## 1. Create the role

- [x] 1.1 Add `modules/ROLES/home-pim-cli-server-dev.nix` defining `flake.modules.homeManager.role-pim-cli-server-dev`
- [x] 1.2 Have the role import `vibecoding-claude-code-config` (additive; do NOT re-import `role-pim-cli-minimal`), following the sibling-role style of `home-pim-cli-full.nix`

## 2. Wire into durer

- [x] 2.1 In `modules/HOSTS/durer-server/configuration.nix`, add `role-pim-cli-server-dev` to the `pim@durer` home config imports (alongside the existing `role-pim-cli-minimal`). Note: the new role file had to be `git add`ed (intent-to-add) so the flake's `import-tree ./modules` would see it.

## 3. Build and verify

- [x] 3.1 Build the `pim@durer` home configuration successfully. Verified: `nix build .#homeConfigurations."pim@durer".activationPackage` succeeds and `claude` (claude-code-2.1.158) is present at `home-path/bin/claude`.
- [ ] 3.2 Deploy to durer and confirm `claude` is on PATH over SSH
- [ ] 3.3 Confirm the `mip:flaker` and `mip:translate` slash commands are present in Claude Code on durer
- [x] 3.4 Confirm `role-pim-cli-minimal`-only hosts (e.g. a Raspberry Pi) are unchanged. Verified structurally: `role-pim-cli-server-dev` is imported only by `pim@durer`; `pim@hurry`/`pim@harry` import only `role-pim-cli-minimal`, which was left untouched — so no Claude Code is added to the Pis.
