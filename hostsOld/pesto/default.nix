{ ... }:
{
  imports = [
    ./hardware.nix
    ./pine-home-manager.nix
    ./pine-phosh.nix
    ./pine-users.nix
    ./pine-apps.nix
  ];

  system.stateVersion = "22.05";
  nixpkgs.config.allowUnfree = true;
  #services.openssh.settings.PermitRootLogin = true;
}
