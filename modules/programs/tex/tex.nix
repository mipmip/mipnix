{ inputs, ... } : {
  flake.modules.nixos.tex-main = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [

      texlive.combined.scheme-full
      pandoc
      quarto
      librsvg
      jupyter


    ];
  };
}
