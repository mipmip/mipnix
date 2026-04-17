{
inputs,
...
}:
{
  flake.modules.homeManager.pim-git = { pkgs, ... }: {
    home.packages = [
      inputs.specgetty.packages."${pkgs.stdenv.hostPlatform.system}".specgetty
    ];

    home.file = {
      "./.config/specgetty/config.yml" = {
        source = ./config.yml;
      };
    };
  };
}
