{
inputs,
...
}:
{
  flake.modules.homeManager.pim-aoe = { pkgs, ... }: {
    home.packages = [
      inputs.aoe.packages."${pkgs.stdenv.hostPlatform.system}".default
    ];
  };
}

