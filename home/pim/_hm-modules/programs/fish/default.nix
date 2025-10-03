{ config, pkgs, lib, ... }:

let
  cfg = config.roles.secondbrain;
in
  {

  options.fish.enable = lib.mkEnableOption "enable fish";
  config = lib.mkMerge
    [
      (lib.mkIf config.fish.enable {

        programs.fish = {
          enable = true;

          #          sessionVariables = {
          #            BROWSER = "firefox";
          #            COLORTERM = "truecolor";
          #            PATH= "''$HOME/.npm-packages/bin:''$PATH";
          #            NODE_PATH="''$HOME/.npm-packages/lib/node_modules";
          #          };

          shellAliases = {

            open = "xdg-open";

            t = lib.mkDefault "tmux a || smug start lobby && smug start sudo && smug start nixos && smug start tekst";

            lin = "vim -c LinnyStart";

            tn = "tmux new -d -s";
            tmxa = "tmux unbind C-a && tmux set-option -g prefix C-a && tmux bind-key C-a send-prefix";
            tmxb = "tmux unbind C-b && tmux set-option -g prefix C-b && tmux bind-key C-b send-prefix";
            mip = "WEBKIT_DISABLE_DMABUF_RENDERER=1 mip";

            smugs = lib.mkDefault "smug && smug start sudo && smug start nixos && smug start lobby";
            smugs_q = "smug start quiqr_dev_run && smug start quiqr_data";
            smugs_tn = "smug start technative_aws && smug start technative_docs && smug start technative_weare";

            crb_status = "mount | grep /mnt/cryptobox";
            crb_mount = "crb_status || sudo cryptobox --mount $HOME/Nextcloud/Vaults/keys.luks.ext4.img /mnt/cryptobox";
            crb_umount = "sudo umount /mnt/cryptobox";
            crb_diff = "diff -qr ~/.aws /mnt/cryptobox/encrypim/.aws; diff -qr ~/.ssh /mnt/cryptobox/encrypim/.ssh";

            # technative
            #tn_aws_mfa = "aws-mfa --profile technative --device arn:aws:iam::521402697040:mfa/pim@technative.nl";

            firefox_with_yellow_car = "MOZ_ENABLE_WAYLAND=0 proxychains4 firefox -P adevinta --class ffextra --no-remote";

            sshpw = "ssh -o PubkeyAuthentication=no -o PreferredAuthentications=password";

            #hm_reset_envs = "unset __HM_SESS_VARS_SOURCED __HM_ZSH_SESS_VARS_SOURCED && source ~/.zshenv";
            aiderbrclaude37 = ''AWS_REGION_NAME=eu-central-1 \
              AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_BEDROCK_PIM \
              AWS_SECRET_ACCESS_KEY=$AWS_ACCESS_KEY_BEDROCK_PIM_SECRET \
              aider --model bedrock/eu.anthropic.claude-3-7-sonnet-20250219-v1:0'';
            aiderbrclaude40 = ''AWS_REGION_NAME=eu-central-1 \
              AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_BEDROCK_PIM \
              AWS_SECRET_ACCESS_KEY=$AWS_ACCESS_KEY_BEDROCK_PIM_SECRET \
              aider --model bedrock/anthropic.claude-sonnet-4-20250514-v1:0'';
            aiderbrclaude45 = ''AWS_REGION_NAME=eu-central-1 \
              AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_BEDROCK_PIM \
              AWS_SECRET_ACCESS_KEY=$AWS_ACCESS_KEY_BEDROCK_PIM_SECRET \
              aider --model bedrock/anthropic.claude-sonnet-4-5-20250929-v1:0'';
            aiderbrmeta32 = ''AWS_REGION_NAME=eu-central-1 \
              AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_BEDROCK_PIM \
              AWS_SECRET_ACCESS_KEY=$AWS_ACCESS_KEY_BEDROCK_PIM_SECRET \
              aider --model bedrock/meta.llama3-2-3b-instruct-v1:0'';
          };

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

            #bass export PATH=~/.npm-packages/bin:$PATH

          '';

        };
      })


      (lib.mkIf config.roles.secondbrain.enable {

        programs.fish.shellAliases = {
          t = "tmux a || smug start lobby && smug start doen && smug start sudo && smug start nixos && smug start tekst";
          smugs = "smug start doen && smug start sudo && smug start nixos && smug start lobby";
          #nlin = "tmux set -p allow-passthrough on && nvim -c LinnyStart $HOME/secondbrain/wikiContent/doen_werk.md";
          nlin = "nvim -c LinnyStart $HOME/secondbrain/content/doen_werk.md";
          nvim = "nvim";
        };

      })
    ];
}
