{ inputs, ... } : {
  flake.modules.nixos.plymouth-grannyos = { pkgs, ... }: {

    imports = [
      inputs.nixos-boot-grannyos.nixosModules.default
    ];
  };
}



