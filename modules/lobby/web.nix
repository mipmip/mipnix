{ inputs, ... }:
{
  flake.modules.nixos.lobby-web = { config, lib, pkgs, ... }:
    let
      meshIP = inputs.self.nebulaNodes.${config.networking.hostName};
    in
    {
      services.nginx = {
        enable = true;
        virtualHosts.lobby = {
          serverName = "lobby";
          default = true;
          listen = [ { addr = meshIP; port = 80; } ];
          root = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.lobby-web;
        };
      };

      systemd.services.nginx = {
        after = [ "nebula@mesh.service" ];
        startLimitIntervalSec = lib.mkForce 0;
        serviceConfig = {
          Restart = lib.mkForce "always";
          RestartSec = lib.mkForce 5;
        };
      };
    };
}
