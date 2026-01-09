{ inputs, ... } : {
  flake.modules.nixos.tui-hardware = { config, pkgs, ... }: {

    environment.systemPackages = with pkgs; [
      dmidecode
      pciutils
      #glxinfo
      lm_sensors
      usbutils
      linux-firmware
    ];
  };
}
