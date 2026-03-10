{ pkgs, ... }:
{
  extraPlugins = [

    (pkgs.vimUtils.buildVimPlugin {
      name = "linny";
      src = pkgs.fetchFromGitHub {
        owner = "linden-project";
        repo = "linny.vim";
        rev = "d5922061bd10e215bbcec71159411e32c898221e";
        hash = "sha256-R7jEtHuXZBclwevBwJ9HMY2IyQJ11GQovW/CEdFYWSo=";
      };
    })

  ];

  extraConfigLua =
    ''
      local secondbrain_path = os.getenv("HOME") .. "/secondbrain"
      local stat = vim.uv.fs_stat(secondbrain_path)
      if stat and stat.type == "directory" then
        vim.g.linny_open_notebook_path = vim.env.HOME .. '/secondbrain'
        vim.g.linny_hugo_watch_enabled = 1
      end
    '';
}
