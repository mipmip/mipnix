{
...
}:
let
  hostname = "durer";
in
{

  flake.nebulaNodes.durer = "192.168.100.12";

  flake.modules.nixos.durer = { config, pkgs, ... } : {

    security.sudo.wheelNeedsPassword = false;

    networking.hostName = hostname;
    networking.firewall.enable = true;
    networking.firewall.allowedTCPPorts = [ 22 80 443 ];
    networking.firewall.allowedUDPPorts = [ 4242 ];

    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };

    age = {
      secrets = {
        "nebula-${hostname}-key" = {
          file = ../../../secrets + "/nebula-${hostname}.key.age";
          path = "/var/lib/nebula/nebula-${hostname}.key";
          owner = "nebula-mesh";
          group = "root";
          mode = "600";
        };
        "nebula-${hostname}-cert" = {
          file = ../../../secrets + "/nebula-${hostname}.crt.age";
          path = "/var/lib/nebula/nebula-${hostname}.crt";
          owner = "nebula-mesh";
          group = "root";
          mode = "600";
        };
      };
    };
    # durer is the second nebula lighthouse (Hetzner, stable public IPv4).
    mipnix.nebula.isLighthouse = true;

    services.nebula.networks.mesh = {
      cert = config.age.secrets."nebula-${hostname}-cert".path;
      key = config.age.secrets."nebula-${hostname}-key".path;
    };


  };
}
