{ inputs, ... } : {
  flake.modules.nixos.desktop-myhotkeys = { pkgs, ... }: {
    environment.systemPackages = [
      inputs.myhotkeys.packages."${pkgs.stdenv.hostPlatform.system}".myhotkeys
    ];
  };
}

