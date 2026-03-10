{ pkgs, ... }:
{
  extraPlugins = [

    (pkgs.vimUtils.buildVimPlugin {
      name = "linny";
      src = pkgs.fetchFromGitHub {
        owner = "linden-project";
        repo = "linny.vim";
        rev = "f1e4977be9e3b52f02f6e91411376df9a9f9f628";
        hash = "sha256-834xi/VfkqXBRNtyrZxFecl8mQiYpBE+Qlnnp4tnf+U=";
      };
    })

  ];

  extraConfigLua =
    ''
      local secondbrain_path = os.getenv("HOME") .. "/secondbrain"
      local stat = vim.uv.fs_stat(secondbrain_path)
      if stat and stat.type == "directory" then
        vim.g.linny_open_notebook_path = vim.env.HOME .. '/secondbrain'
      end
    '';
}
