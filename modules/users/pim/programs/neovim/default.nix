{
  inputs,
  ...
}:
{
  flake.modules.homeManager.pim-neovim =
    {
      pkgs,
      system,
      ...
    }:
    {
      home.packages = [
        inputs.self.packages."${system}".mipvim
      ];
    };
}
