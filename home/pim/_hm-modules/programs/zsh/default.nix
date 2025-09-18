{ config, pkgs, lib, ... }:

let
  cfg = config.roles.secondbrain;
in
  {

  options.zsh.enable = lib.mkEnableOption "enable zsh";

  config = lib.mkMerge
    [
      (lib.mkIf config.zsh.enable {

          home.file = {
            ".ohmyzsh-pim" = {
              source = ./ohmyzsh-pim;
              recursive = true;
            };
          };

          programs.zsh = {
            enable = true;
            autocd = true;
            autosuggestion.enable = false;

            sessionVariables = {
              BROWSER = "firefox";
              COLORTERM = "truecolor";
              PATH= "''$HOME/.npm-packages/bin:''$PATH";
              NODE_PATH="''$HOME/.npm-packages/lib/node_modules";
            };

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

              hm_reset_envs = "unset __HM_SESS_VARS_SOURCED __HM_ZSH_SESS_VARS_SOURCED && source ~/.zshenv";
              aiderbrclaude37 = ''AWS_REGION_NAME=eu-central-1 \
              AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_BEDROCK_PIM \
              AWS_SECRET_ACCESS_KEY=$AWS_ACCESS_KEY_BEDROCK_PIM_SECRET \
              aider --model bedrock/eu.anthropic.claude-3-7-sonnet-20250219-v1:0'';
            };

            plugins = [
              {
                name = "zsh-nix-shell";
                file = "nix-shell.plugin.zsh";
                src = pkgs.fetchFromGitHub {
                  owner = "chisui";
                  repo = "zsh-nix-shell";
                  rev = "v0.4.0";
                  sha256 = "037wz9fqmx0ngcwl9az55fgkipb745rymznxnssr3rx9irb6apzg";
                };
              }
            ];

            oh-my-zsh = {
              enable = true;
              theme = "pim";
              custom = "$HOME/.ohmyzsh-pim";
              plugins=["git terraform aws mix"];
            };
            initContent = ''
            if [[ -n "$IN_NIX_SHELL" ]]; then
              label="nix-shell"
              if [[ "$name" != "$label" ]]; then
                label="$label:$name"
              fi
              export PS1=$'%{$fg[green]%}'"$label$PS1"
              unset label
            fi

            set -o allexport
            source /tmp/openai-api-key
            source /tmp/bedrockpim-api-keys-env
            source /tmp/bedrock-keys-for-avante-env
            set +o allexport

            export PATH=~/.npm-packages/bin:$PATH

            '';
          };
        })


      (lib.mkIf config.roles.secondbrain.enable {

        programs.zsh.shellAliases = {
          t = "tmux a || smug start lobby && smug start doen && smug start sudo && smug start nixos && smug start tekst";
          smugs = "smug start doen && smug start sudo && smug start nixos && smug start lobby";
          #nlin = "tmux set -p allow-passthrough on && nvim -c LinnyStart $HOME/secondbrain/wikiContent/doen_werk.md";
          nlin = "nvim -c LinnyStart $HOME/secondbrain/content/doen_werk.md";
          nvim = "nvim";
        };

      })
    ];


}

