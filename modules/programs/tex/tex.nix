{ inputs, ... } : {
  flake.modules.nixos.tex-main = { config, lib, pkgs, ... }:
    let
      cfg = config.mipnix.tex;
    in
    {
      options.mipnix.tex.full = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Install the full TeX Live scheme together with quarto and jupyter.
          Set to false on a host that only needs to render the occasional
          document: texlive-small plus pandoc covers that in 0.6 GB where the
          full set costs over 9 GB of store.
        '';
      };

      config.environment.systemPackages = with pkgs; [
        pandoc
        librsvg
      ] ++ (
        if cfg.full then [
          texlive.combined.scheme-full
          quarto
          jupyter
        ] else [
          texliveSmall
        ]
      );
    };
}
