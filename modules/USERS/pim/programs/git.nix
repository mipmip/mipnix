{
inputs,
...
}:
{
  flake.modules.homeManager.pim-git = { pkgs, ... }:{
    programs.git = {
      enable = true;
      settings = {
        user = {
          name = "Pim Snel";
          email = "post@pimsnel.com";
        };

        # add git config pull.rebase

        init = {
          defaultBranch = "main";
        };
        safe = {
          directory = "/etc/nixos";
        };
      };
    };

  };
}
