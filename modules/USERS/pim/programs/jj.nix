{
inputs,
config,
...
}:
{
  flake.modules.homeManager.pim-git = { pkgs, ... }:{

    home.packages = [
      pkgs.jjui
      pkgs.lazyjj
    ];

    programs.jujutsu = {
      enable = true;
      settings = {
        user = {
          name = "Pim Snel";
          email = "post@pimsnel.com";
        };
        ui = {
          default-command = ["log" "--no-pager"];
        };
        #        git = {
        #          push-branch-prefix = "refs/heads/";
        #          push-default = "current";
        #        };
        #        signing = {
        #          sign-all = true;
        #          backend = "gpg";
        #        };
        #        "template-aliases" = {
        #          "format_timestamp(timestamp)" = "timestamp.ago()";
        #        };
      };
    };


  };
}


