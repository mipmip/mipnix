{ inputs, ... } : {
  flake.modules.nixos.desktop-apps-markdown = { config, pkgs, inputs, ... }: {
    environment.systemPackages = with pkgs; [

      inputs.mip.packages."${ pkgs.stdenv.hostPlatform.system }".default

    ];
  };
}
