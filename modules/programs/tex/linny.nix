{ inputs, ... } : {
  flake.modules.nixos.tex-linny = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      inputs.fred.packages."${pkgs.stdenv.hostPlatform.system}".fred
      ruby # for Linny
      sc-im
      pkgs.unstable.hugo
    ];
  };
}
