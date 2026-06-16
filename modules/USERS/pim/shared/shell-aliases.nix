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
          #vim = "nvim";
          signal = ''signal-desktop --password-store="gnome-libsecret"'';

          lin = "vim -c LinnyStart";

          t = lib.mkDefault "tmux a || smug start lobby && smug start sudo && smug start nixos && smug start tekst";
          tmxa = "tmux unbind C-a && tmux set-option -g prefix C-a && tmux bind-key C-a send-prefix";
          tmxb = "tmux unbind C-b && tmux set-option -g prefix C-b && tmux bind-key C-b send-prefix";

          twn = ''
          tmux rename-window "$(basename "$PWD")"
          '';

          #mip = "WEBKIT_DISABLE_DMABUF_RENDERER=1 mip";

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

          gi = "gh issue";
          gil = "gh issue list";
          gin = ''gh issue create -b "" -t '';
          gic = ''gh issue close '';
          gib = ''gh browse'';
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
