{
  inputs,
  ...
}:
{
  flake.modules.homeManager.pim-noctalia = { pkgs, ... }: {

    imports = [
      inputs.noctalia.homeModules.default
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
