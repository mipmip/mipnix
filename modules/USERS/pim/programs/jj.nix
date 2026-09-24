{
inputs,
config,
...
}:
{
  # jj cheatsheet entries. The abbreviations are defined in fish's
  # interactiveShellInit rather than in shared.shellAliases, because they use
  # `--set-cursor`, which an alias cannot express. So they are documented here
  # rather than emitted, the same way the git plugin abbreviations are.
  flake.hotkeys =
    let
      w = word: desc: {
        kind = "word"; app = "jj"; scopes = [ "terminal" ];
        inherit word desc;
      };
    in
    [
      (w "jc" "commit: describe @ and start a new change (fish abbreviation)")
      (w "jp" "publish: jj tug && jj git push (fish abbreviation)")
      (w "jj tug" "move the closest bookmark up to @-")

      (w "jj" "log the recent history")
      (w "jj st" "what changed in the working copy")
      (w "jj new" "start a new empty change on top")
      (w "jj new <rev>" "start a new change on top of another revision")
      (w "jj describe -m" "set the message of the current change")
      (w "jj edit <rev>" "move the working copy to an existing change")
      (w "jj diff" "diff of the current change")
      (w "jj diff -r <rev>" "diff of another revision")
      (w "jj log -r <revset>" "log a revset, for example all() or mine()")

      (w "jj squash" "fold the current change into its parent")
      (w "jj squash -i" "fold interactively, choosing hunks")
      (w "jj split" "split the current change in two")
      (w "jj absorb" "push each hunk into the change that introduced it")
      (w "jj abandon" "throw the current change away")
      (w "jj restore <path>" "discard changes to a path")
      (w "jj rebase -d <rev>" "move a change onto another parent")

      (w "jj undo" "undo the last operation")
      (w "jj op log" "the operation log, everything jj has done")
      (w "jj op restore <op>" "rewind the whole repo to an operation")

      (w "jj bookmark list" "list bookmarks")
      (w "jj bookmark set <name>" "point a bookmark at the current change")
      (w "jj git fetch" "fetch from the git remote")
      (w "jj git push" "push bookmarks to the git remote")

      (w "jjui" "jj terminal UI")
      (w "lazyjj" "the other jj terminal UI")
    ];

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


