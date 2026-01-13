{
inputs,
...
}:
{
  flake.modules.homeManager.pim-shellstuff = { pkgs, ... }: {
    home.packages = [
      inputs.shellstuff.packages."${pkgs.system}".shellstuff
    ];
  };
}
