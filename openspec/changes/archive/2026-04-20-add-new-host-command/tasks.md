## 1. Add new_host function to RUNME.sh

- [x] 1.1 Add `make_command "new_host"` declaration and function skeleton with gum dependency check
- [x] 1.2 Add gum prompts for hostname, type suffix, and architecture (gum choose for arch)
- [x] 1.3 Add duplicate host directory check and confirmation summary
- [x] 1.4 Implement hardware.nix auto-wrapping: read `/etc/nixos/hardware-configuration.nix`, extract body via sed, write wrapped in flake module pattern
- [x] 1.5 Implement configuration.nix generation with heredoc template (homeConfigurations, nixosConfigurations, nixos module with base imports)
- [x] 1.6 Implement networking.nix generation with heredoc template (hostName + firewall)
- [x] 1.7 Add optional nebula prompt that calls `new_nebula_node` if confirmed
- [x] 1.8 Add success message with gum style showing created files and next steps
