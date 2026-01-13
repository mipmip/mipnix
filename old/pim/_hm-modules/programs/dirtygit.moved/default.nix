{ inputs, pkgs, system, ... }:

{
  home.packages = [
    inputs.dirtygit.packages."${pkgs.system}".dirtygit
  ];

  home.file = {
    "./.dirtygit.yml" = {
      source = ./dirtygit.yml;
    };
  };

}
