{ inputs, ... } : {
  flake.modules.nixos.desktop-apps-dtp = { config, lib, pkgs, ... }:
    let
      cfg = config.mipnix.desktop;
    in
    {
      options.mipnix.desktop.authoring = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Install the image, vector, 3D and office authoring suite. Set to
          false on a machine that is used for code rather than for making
          things to look at; the suite costs around 8 GB of store.
        '';
      };

      config.environment.systemPackages = with pkgs; [
        feh
        emulsion-palette
      ] ++ lib.optionals cfg.authoring [
        # TODO which gimp shall we choose here?
        gimp
        gimp3-with-plugins

        inkscape-with-extensions
        blender
        libreoffice
      ];
    };
}
