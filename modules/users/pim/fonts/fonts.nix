{
inputs,
...
}:
{
  flake.modules.homeManager.pim-fonts = {
    fonts.fontconfig.enable = true;
    #    home.packages = [
    #      (pkgs.nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
    #    ];
  };
}
