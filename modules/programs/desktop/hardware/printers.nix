{ inputs, ... } : {
  flake.modules.nixos.desktop-hw-printers = { config, pkgs, ... }: {
    services.printing.enable = true;
  };
}
