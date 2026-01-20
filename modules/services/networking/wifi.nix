{ inputs, ... } : {
  flake.modules.nixos.networking-wifi = { pkgs, config, ... }: {

    # Automatically set the regulatory domain for
    # the wireless network card
    hardware.wirelessRegulatoryDatabase = true;
  };
}
