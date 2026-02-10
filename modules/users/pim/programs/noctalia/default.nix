{
  inputs,
  ...
}:
{
  flake.modules.homeManager.pim-noctalia = { pkgs, ... }: {

    imports = [
      inputs.noctalia.homeModules.default
    ];
    home.packages = [
      pkgs.quickshell
    ];

    programs.noctalia-shell = {
      enable = true;
      systemd.enable = true;
      settings = {
        # Basic settings - can be customized later
      };
    };

  };
}
