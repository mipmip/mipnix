{ pkgs, ... }:
{
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "openspec.nvim";
      src = pkgs.fetchFromGitHub {
        owner = "speclib";
        repo = "openspec.nvim";
        rev = "328ea151b2f930d661cca9638ecec69c113ec631";
        hash = "sha256-q4VQxQ6/3RDGe/s4wccRSLxMXJtxGbz4RKOuNyvWskA=";
      };
    })
  ];

  extraConfigLua = ''
    require("openspec").setup({ neotree = true })
  '';
}
