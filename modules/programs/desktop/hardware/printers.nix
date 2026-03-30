{ inputs, ... } : {
  flake.modules.nixos.desktop-hw-printers = { config, pkgs, ... }: {
    services.printing.enable = true;
    environment.systemPackages = with pkgs; [
      cups-brother-hl1210w
    ];
  };
}
