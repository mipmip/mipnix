{ inputs, ... } : {
  flake.modules.nixos.plymouth-grannyos = { pkgs, ... }: {

    nixos-boot = {
      enable  = true;
      theme = "grannyos";

      bgColor.red   = 0; # 0 - 255
      bgColor.green = 212; # 0 - 255
      bgColor.blue  = 255; # 0 - 255

      # If you want to make sure the theme is seen when your computer starts too fast
      # duration = 3; # in seconds
    };


    imports = [
      inputs.nixos-boot-grannyos.nixosModules.default
    ];
  };
}



