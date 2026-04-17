{
  flake.modules.nixos.user-pim = { config, pkgs, ... }: {

    programs.fish.enable = true;
    users.users.pim = {
      shell = pkgs.fish;
      isNormalUser = true;
      extraGroups = [ "wheel" "docker" "networkmanager" "disk" "input"];
    };
  };
}
