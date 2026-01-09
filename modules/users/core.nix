{ inputs, ... } : {
  flake.modules.nixos.users-core = { config, pkgs, ... }: {

    services.openssh.enable = true;
    services.cron.enable = true;
    services.journald.extraConfig = "SystemMaxUse=100M";

    programs.zsh.enable = true;
    programs.fish.enable = true;
    environment.shells = with pkgs; [ zsh fish bash ];

    #programs.ssh.startAgent = true;

    security.sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };

    users.defaultUserShell = pkgs.fish;

    users.users.pim = {
      shell = pkgs.fish;
      isNormalUser = true;
      extraGroups = [ "wheel" "docker" "networkmanager" "disk"];
    };

    users.users.distrobox = {
      isNormalUser = true;
      extraGroups = [ "wheel" "docker" "networkmanager" "disk"];
    };

    users.users.tim = {
      isNormalUser = true;
      extraGroups = [ "wheel" "docker" "networkmanager" "disk"];
    };

    users.users.annemarie = {
      isNormalUser = true;
      extraGroups = [ "wheel" "docker" "networkmanager" "disk"];
    };

    users.users.guest = {
      isNormalUser = true;
      extraGroups = [ "networkmanager" ];
    };

  };
}
