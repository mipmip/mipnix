{
inputs,
...
}:
{
  flake.modules.homeManager.pim-jjay = {pkgs,...} : {
    home.packages = [
      inputs.jjay.packages."${pkgs.stdenv.hostPlatform.system}".default
    ];
  };
}
