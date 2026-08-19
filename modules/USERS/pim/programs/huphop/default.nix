{
inputs,
...
}:
{
  flake.modules.homeManager.pim-huphop = { lib, pkgs, ... }: {
    home.packages = [
      inputs.huphop.packages."${pkgs.stdenv.hostPlatform.system}".default
    ];
  };
}
