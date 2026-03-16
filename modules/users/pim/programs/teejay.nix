{
inputs,
...
}:
{
  flake.modules.homeManager.pim-ghostty = {pkgs,...} : {
    home.packages = [
      inputs.teejay.packages."${pkgs.stdenv.hostPlatform.system}".teejay
    ];
  };
}
