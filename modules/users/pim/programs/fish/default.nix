{
inputs,
...
}:
{
  flake.modules.homeManager.pim-fish = { config, pkgs, lib, ... }: {
    options.fish.enable = lib.mkEnableOption "enable fish";

    config = lib.mkMerge [
      (lib.mkIf config.fish.enable {
        programs.fish = {
          enable = true;

          #          sessionVariables = {
          #            BROWSER = "firefox";
          #            COLORTERM = "truecolor";
          #            PATH= "''$HOME/.npm-packages/bin:''$PATH";
          #            NODE_PATH="''$HOME/.npm-packages/lib/node_modules";
          #          };

          shellAliases = config.shared.shellAliases;

          plugins = with pkgs; [
            { name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src; }
            #{ name = "tide"; src = pkgs.fishPlugins.tide.src; }
            { name = "bass"; src = pkgs.fishPlugins.bass.src; }
            { name = "gruvbox"; src = pkgs.fishPlugins.gruvbox.src; }
          ];

          interactiveShellInit = ''

            set fish_greeting # Disable greeting

            set -l nix_shell_info (
              if test -n "$IN_NIX_SHELL"
                echo -n "<nix-shell> "
              end
            )

            abbr --add fd --set-cursor=° 'fd --color always ° | sort | less'

            function prompt_path_simple
              if test $PWD != $HOME
                path basename (pwd)
              else
                echo "~"
              end
            end

            function prompt_user
              whoami
            end

            function git_is_dirty
              git diff-index --quiet HEAD -- && echo clean >/tmp/myreponame.status
            end


            function _pure_prompt_git_dirty
                set --local git_dirty_symbol
                set --local git_dirty_color

                set --local is_git_dirty (
                    # HEAD may not exist (e.g. immediately after git init); diff-index is
                    # fast for staged checks but requires a ref.
                    #
                    # The diff-index (or diff --staged) checks for staged changes; the diff
                    # checks for unstaged changes; the ls-files checks for untracked files.
                    # We put them in this order because checking staged changes is *fast*.
                    if command git rev-list --max-count=1 HEAD -- >/dev/null 2>&1;
                        not command git diff-index --ignore-submodules --cached --quiet HEAD -- >/dev/null 2>&1;
                    else;
                        not command git diff --staged --ignore-submodules --no-ext-diff --quiet --exit-code >/dev/null 2>&1;
                    end
                    or not command git diff --ignore-submodules --no-ext-diff --quiet --exit-code >/dev/null 2>&1
                    or command git ls-files --others --exclude-standard --directory --no-empty-directory --error-unmatch -- ':/*' >/dev/null 2>&1
                    and echo "true"
                )
                if test -n "$is_git_dirty"  # untracked or un-commited files
                  echo -s (set_color -o yellow) "✗"
                end

            end

            function pim_git_prompt
              set --local gp (fish_git_prompt)
              set --local dirty (_pure_prompt_git_dirty)

              if test -n "$gp"
                if test -n "$dirty"
                  echo -s (fish_git_prompt) " " (_pure_prompt_git_dirty) " "
                else
                  echo -s (fish_git_prompt) " "
                end
              else
                echo -s " "
              end
            end

            function fish_prompt
              set -l prompt_symbol '$'
              fish_is_root_user; and set prompt_symbol '#'

              echo -s 🐟 " " \
                (set_color -o purple) (prompt_user) \
                (set_color -o blue) "@" (prompt_hostname) " " \
                (set_color -o green) (prompt_path_simple) \
                (set_color -o red) (pim_git_prompt) \
                (set_color -o white) $prompt_symbol " " \
                (set_color normal)
            end

            bass source /tmp/openai-api-key
            bass source /tmp/bedrockpim-api-keys-env
            bass source /tmp/bedrock-keys-for-avante-env

            set -gx EDITOR nvim


            #bass export PATH=~/.npm-packages/bin:$PATH

          '';

        };
      })
    ];
  };
}
