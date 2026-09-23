# Schema: tinychange (https://github.com/speclib/openspec-tinychange-schema)

## 1. Implementation

- [x] 1.1 In `modules/HOSTS/doornappel-laptop/configuration.nix`, added
      `powerManagement.enable = true;` to the `hardware.nvidia = { … }` block (installs the
      nvidia-suspend/resume/hibernate services that preserve VRAM across suspend, fixing the
      `[nvidia-drm] Failed to allocate NVKMS memory` errors on resume)

## 2. Verification

- [x] 2.1 `nix-instantiate --parse` OK; `nix eval` confirms
      `nixosConfigurations.doornappel.config.hardware.nvidia.powerManagement.enable` = `true`
- [ ] 2.2 Post-rebuild: `systemctl list-unit-files 'nvidia-*'` lists nvidia-suspend/resume/hibernate
      (NEEDS REBUILD)
- [ ] 2.3 Post-rebuild: suspend then resume; confirm the display restores and
      `journalctl -k -b 0 | grep 'Failed to allocate NVKMS'` is empty (NEEDS REBUILD + a sleep cycle)
