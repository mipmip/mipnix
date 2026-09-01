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
        revset-aliases = {
          "closest_bookmark(to)" = "heads(::to & bookmarks())";
        };
        aliases = {
          tug = ["bookmark" "move" "--from" "closest_bookmark(@-)" "--to" "@-"];
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


