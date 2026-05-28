{ ... }:

let
  hostname = "clawone";
in
{

  flake.modules.nixos.clawone = { config, pkgs, lib, ... }: {

    networking.hostName = hostname;

    systemd.network.enable = true;

    systemd.network.networks."20-eth0" = {
      matchConfig.Name = "eth0";
      addresses = [{ Address = "10.0.100.2/24"; }];
      routes = [{ Gateway = "10.0.100.1"; }];
      dns = [ "1.1.1.1" "8.8.8.8" ];
      networkConfig.DHCP = "no";
    };

  };

}
