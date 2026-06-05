## 1. Create the role

- [ ] 1.1 Add `modules/ROLES/home-pim-cli-server-dev.nix` defining `flake.modules.homeManager.role-pim-cli-server-dev`
- [ ] 1.2 Have the role import `vibecoding-claude-code-config` (additive; do NOT re-import `role-pim-cli-minimal`), following the sibling-role style of `home-pim-cli-full.nix`

## 2. Wire into durer

- [ ] 2.1 In `modules/HOSTS/durer-server/configuration.nix`, add `role-pim-cli-server-dev` to the `pim@durer` home config imports (alongside the existing `role-pim-cli-minimal`)

## 3. Build and verify

- [ ] 3.1 Build the `pim@durer` home configuration successfully
- [ ] 3.2 Deploy to durer and confirm `claude` is on PATH over SSH
- [ ] 3.3 Confirm the `mip:flaker` and `mip:translate` slash commands are present in Claude Code on durer
- [ ] 3.4 Confirm `role-pim-cli-minimal`-only hosts (e.g. a Raspberry Pi) are unchanged (no Claude Code added)
