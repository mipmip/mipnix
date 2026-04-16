{
...
}:
let
  hostname = "dapperehaan";
in
{
  flake.modules.nixos.dapperehaan = { config, pkgs, ... } : {

    networking.hostName = hostname;
    networking.firewall.enable = false;

  };
}
