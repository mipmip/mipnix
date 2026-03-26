{
  flake.modules.nixos.user-pim = { config, pkgs, ... }: {

    users.users.pim = {
      shell = pkgs.fish;
      isNormalUser = true;
      extraGroups = [ "wheel" "docker" "networkmanager" "disk"];
    };
  };
}
