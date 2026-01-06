{ config, lib, pkgs, ... }:{

  config = lib.mkIf config.nixos.desktop.enable {
    # Enable CUPS to print documents.
    services.printing.enable = true;
    #services.printing.drivers = [
    #  (pkgs.callPackage ../../pkgs/drivers/hl4150cdn/default.nix {})
    #];

    environment.systemPackages = with pkgs; [
      #mipmip_pkg.hl4150cdn
    ];
  };
}



