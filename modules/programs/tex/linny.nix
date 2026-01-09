{ inputs, ... } : {
  flake.modules.nixos.tex-linny = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      mipmip_pkg.fred # needed for linny
      ruby # for Linny
      sc-im
      pkgs.unstable.hugo
    ];
  };
}
