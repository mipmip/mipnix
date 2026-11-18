{ inputs, pkgs, ... }:
{
  extraPackages = [
    inputs.linden-index.packages.${pkgs.stdenv.hostPlatform.system}.lindexer
  ];

  extraPlugins = [

    (pkgs.vimUtils.buildVimPlugin {
      name = "linny";
      src = pkgs.fetchFromGitHub {
        owner = "linden-project";
        repo = "linny.vim";
        rev = "a890e4affa1cae3a1b860c147d3b7e3fc70b7bb9";
        hash = "sha256-db9XYGK/xzty9BYvwnOr+mc6Ceho3GT6+RqpTaqzslI=";
      };
    })

  ];

  extraConfigLua =
    ''
      local secondbrain_path = os.getenv("HOME") .. "/secondbrain"
      local stat = vim.uv.fs_stat(secondbrain_path)
      if stat and stat.type == "directory" then
        vim.g.linny_open_notebook_path = vim.env.HOME .. '/secondbrain'
        vim.g.linny_index_watch_enabled = 1
      end
    '';
}
