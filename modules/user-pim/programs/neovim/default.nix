{
  inputs,
  ...
}:
{
  flake.modules.homeManager.pim-neovim =
    {
      pkgs,
      ...
    }:
    {
      home.packages = [
        inputs.self.packages."${pkgs.stdenv.hostPlatform.system}".mipvim
        pkgs.tree-sitter
      ];
    };
}
