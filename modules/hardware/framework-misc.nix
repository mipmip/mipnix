{ inputs, ... } : {
  flake.modules.nixos.framework-misc = { config, pkgs, ... }: {

    hardware.sensor.iio.enable = true;

  };
}

