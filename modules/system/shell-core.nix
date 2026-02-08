{ inputs, ... } : {
  flake.modules.nixos.shell-core = { config, pkgs, ... }: {

    programs.zsh.enable = true;
    programs.fish.enable = true;
    environment.shells = with pkgs; [ zsh fish bash ];

    security.sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };

    users.users.distrobox = {
      isNormalUser = true;
      extraGroups = [ "wheel" "docker" "networkmanager" "disk"];
    };

  };
}
