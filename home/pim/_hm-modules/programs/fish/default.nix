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
          };

          plugins = with pkgs; [
            { name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src; }
            #{ name = "tide"; src = pkgs.fishPlugins.tide.src; }
          ];

          interactiveShellInit = ''
            #set fish_greeting # Disable greeting
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
