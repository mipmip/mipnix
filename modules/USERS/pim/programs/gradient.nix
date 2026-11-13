{
inputs,
...
}:
{
  flake.modules.homeManager.pim-gradient = { pkgs, ... }: {
    home.packages = [
      inputs.gradient.packages."${pkgs.stdenv.hostPlatform.system}".gradient-cli
    ];
  };
}
