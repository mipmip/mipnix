{
  flake.modules.nixos.services-core = { config, pkgs, ... }: {

    services.openssh.enable = true;
    services.cron.enable = true;
    services.journald.extraConfig = "SystemMaxUse=100M";

  };
}
