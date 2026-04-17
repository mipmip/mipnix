{
...
}:
{
  flake.modules.homeManager.pim-yazi = { pkgs, ... }: {
    home.packages = with pkgs; [
      yazi
    ];
  };
}

