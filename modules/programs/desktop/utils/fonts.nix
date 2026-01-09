{ inputs, ... } : {
  flake.modules.nixos.desktop-utils-fonts = { config, pkgs, lib, ... }:
    let
      fontsList = with pkgs; [
        meslo-lg
        awesome
        dejavu_fonts
        open-sans
        inter
        rubik
        lato
        noto-fonts
        noto-fonts-color-emoji
        #fira-code-nerdfont
        liberation_ttf
        #nerdfonts
        #inconsolata-nerdfont
        ubuntu-classic
      ];
    in
      {
        fonts = {
          enableDefaultPackages = true;
          fontconfig.enable = true;
          packages = fontsList ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

          fontconfig = {
            defaultFonts = {
              serif = [  "Liberation Serif"  ];
              sansSerif = [ "Ubuntu" "Vazirmatn" ];
              monospace = [ "Ubuntu Mono" ];
            };
          };
        };
        environment.systemPackages = fontsList;

      };
}
