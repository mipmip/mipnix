{
inputs,
...
}:
{
  flake.modules.homeManager.pim-shared-shell-aliases = { lib, config, ... }: {

    options.shared.shellAliases = lib.mkOption {
      type = with lib.types; attrsOf str;
      default = { };
      example = lib.literalExpression ''
        {
          g = "git";
          "..." = "cd ../..";
        }
      '';
      description = ''
        An attribute set that maps aliases (the top level attribute names
        in this option) to command strings or directly to build outputs.
      '';
    };

    config = lib.mkMerge [
      {
        shared.shellAliases = {
          open = "xdg-open";
          vim = "nvim";
          signal = ''signal-desktop --password-store="gnome-libsecret"'';

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
          dp = "hyprctl dispatch exec";

          tfswitch = "tfswitch -b $HOME/bin/terraform";

          ns = "nix-search-tv print | fzf --preview 'nix-search-tv preview {}' --scheme history";

          ls = "ls -al";
          fzf = "fzf --preview 'bat --color=always {}'";

          #hm_reset_envs = "unset __HM_SESS_VARS_SOURCED __HM_ZSH_SESS_VARS_SOURCED && source ~/.zshenv";
          aiderbrclaude37 = ''
            AWS_REGION_NAME=eu-central-1 \
                          AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_BEDROCK_PIM \
                          AWS_SECRET_ACCESS_KEY=$AWS_ACCESS_KEY_BEDROCK_PIM_SECRET \
                          aider --model bedrock/eu.anthropic.claude-3-7-sonnet-20250219-v1:0'';

          #          aiderbrclaude40 = ''AWS_REGION_NAME=us-east-1 \
          #              AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_BEDROCK_PIM \
          #              AWS_SECRET_ACCESS_KEY=$AWS_ACCESS_KEY_BEDROCK_PIM_SECRET \
          #              aider --model bedrock/us.anthropic.claude-sonnet-4-20250514-v1:0'';

          aiderbrclaude45 = ''
            AWS_REGION_NAME=us-east-1 \
                          AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_BEDROCK_PIM \
                          AWS_SECRET_ACCESS_KEY=$AWS_ACCESS_KEY_BEDROCK_PIM_SECRET \
                          aider --model bedrock_converse/eu.anthropic.claude-sonnet-4-5-20250929-v1:0'';

          #          aiderbrmeta32 = ''AWS_REGION_NAME=eu-central-1 \
          #              AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_BEDROCK_PIM \
          #              AWS_SECRET_ACCESS_KEY=$AWS_ACCESS_KEY_BEDROCK_PIM_SECRET
          #              aider --model bedrock/eu.meta.llama3-2-3b-instruct-v1:0'';
        };
      }

      (lib.mkIf config.homeWith.secondbrain.enable {

        shared.shellAliases = {
          t = "tmux a || smug start lobby && smug start doen && smug start sudo && smug start nixos && smug start tekst";
          smugs = "smug start doen && smug start sudo && smug start nixos && smug start lobby";
          #nlin = "tmux set -p allow-passthrough on && nvim -c LinnyStart $HOME/secondbrain/wikiContent/doen_werk.md";
          nlin = "nvim -c LinnyStart $HOME/secondbrain/content/doen_werk.md";
          nvim = "nvim";
        };

      })
    ];
  };
}
