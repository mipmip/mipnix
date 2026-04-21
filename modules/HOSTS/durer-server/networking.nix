{
...
}:
let
  hostname = "durer";
in
  {
  flake.modules.nixos.dapperehaan = { config, pkgs, ... } : {

    networking.hostName = hostname;
    networking.firewall.enable = true;

    security.sudo.wheelNeedsPassword = false;

    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };

    networking.firewall.allowedTCPPorts = [ 22 ];


  };
}
