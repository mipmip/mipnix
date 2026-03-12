{
inputs,
...
}:
{
  flake.modules.homeManager.pim-aoe = { pkgs, ... }: {
    home.packages = [
      inputs.aoe.packages."${pkgs.system}".default
    ];
  };
}

