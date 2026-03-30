{ inputs, ... } : {
  flake.modules.nixos.desktop-hw-printers = { config, pkgs, ... }: {
    services.printing.enable = true;
    environment.systemPackages = with pkgs; [
      cups-brother-hl1210w
    ];

    # Add Brother printer drivers
    services.printing.drivers = [
      pkgs.brlaser
      pkgs.cups-brother-hl1210w
      pkgs.brgenml1lpr
      pkgs.brgenml1cupswrapper
    ];
  };
}
