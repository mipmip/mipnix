{
...
}:
let
  hostname = "lavendel";
in
  {
  flake.modules.nixos.lavendel = { config, pkgs, ... } : {

    networking.hostName = hostname;
    networking.networkmanager.enable = true;
    networking.firewall.enable = false;
  };
}
