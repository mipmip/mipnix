{ ... }:
{
  # Shell aliases. The registry is the source: the fish aliases and the
  # cheatsheet entries both come from here, so an alias carries a description
  # for the first time rather than being a bare name to command mapping.
  #
  # The host-conditional overrides stay in shell-aliases.nix, where the option
  # that knows about them lives. Registry values are applied with mkDefault, so
  # those overrides still win.
  flake.hotkeys = [

    { kind = "word"; app = "Shell"; target = "fish"; scopes = [ "terminal" ];
      word = "signal"; desc = "Signal, using the gnome keyring password store";
      action = ''signal-desktop --password-store="gnome-libsecret"''; }

    { kind = "word"; app = "Shell"; target = "fish"; scopes = [ "terminal" ];
      word = "lin"; desc = "Open Linny in vim";
      action = "vim -c LinnyStart"; }

    { kind = "word"; app = "Shell"; target = "fish"; scopes = [ "terminal" ];
      word = "t"; desc = "Attach to tmux, or start the standard sessions";
      action = "tmux a || smug start lobby && smug start sudo && smug start nixos && smug start tekst"; }

    { kind = "word"; app = "Shell"; target = "fish"; scopes = [ "terminal" ];
      word = "tmxa"; desc = "Switch the tmux prefix to Ctrl+A";
      action = "tmux unbind C-a && tmux set-option -g prefix C-a && tmux bind-key C-a send-prefix"; }

    { kind = "word"; app = "Shell"; target = "fish"; scopes = [ "terminal" ];
      word = "tmxb"; desc = "Switch the tmux prefix to Ctrl+B";
      action = "tmux unbind C-b && tmux set-option -g prefix C-b && tmux bind-key C-b send-prefix"; }

    { kind = "word"; app = "Shell"; target = "fish"; scopes = [ "terminal" ];
      word = "twn"; desc = "Rename the tmux window to the current directory";
      action = ''tmux rename-window "$(basename "$PWD")"
''; }

    { kind = "word"; app = "Shell"; target = "fish"; scopes = [ "terminal" ];
      word = "smugs"; desc = "Start the standard smug sessions";
      action = "smug && smug start sudo && smug start nixos && smug start lobby"; }

    { kind = "word"; app = "Shell"; target = "fish"; scopes = [ "terminal" ];
      word = "smugs_q"; desc = "Start the quiqr smug sessions";
      action = "smug start quiqr_dev_run && smug start quiqr_data"; }

    { kind = "word"; app = "Shell"; target = "fish"; scopes = [ "terminal" ];
      word = "smugs_tn"; desc = "Start the technative smug sessions";
      action = "smug start technative_aws && smug start technative_docs && smug start technative_weare"; }

    { kind = "word"; app = "Shell"; target = "fish"; scopes = [ "terminal" ];
      word = "crb_status"; desc = "Show whether the cryptobox is mounted";
      action = "mount | grep /mnt/cryptobox"; }

    { kind = "word"; app = "Shell"; target = "fish"; scopes = [ "terminal" ];
      word = "crb_mount"; desc = "Mount the cryptobox";
      action = "crb_status || sudo cryptobox --mount $HOME/Nextcloud/Vaults/keys.luks.ext4.img /mnt/cryptobox"; }

    { kind = "word"; app = "Shell"; target = "fish"; scopes = [ "terminal" ];
      word = "crb_umount"; desc = "Unmount the cryptobox";
      action = "sudo umount /mnt/cryptobox"; }

    { kind = "word"; app = "Shell"; target = "fish"; scopes = [ "terminal" ];
      word = "crb_diff"; desc = "Compare the cryptobox against ~/.aws and ~/.ssh";
      action = "diff -qr ~/.aws /mnt/cryptobox/encrypim/.aws; diff -qr ~/.ssh /mnt/cryptobox/encrypim/.ssh"; }

    { kind = "word"; app = "Shell"; target = "fish"; scopes = [ "terminal" ];
      word = "firefox_with_yellow_car"; desc = "Firefox through proxychains in the adevinta profile";
      action = "MOZ_ENABLE_WAYLAND=0 proxychains4 firefox -P adevinta --class ffextra --no-remote"; }

    { kind = "word"; app = "Shell"; target = "fish"; scopes = [ "terminal" ];
      word = "sshpw"; desc = "ssh with password authentication only";
      action = "ssh -o PubkeyAuthentication=no -o PreferredAuthentications=password"; }

    { kind = "word"; app = "Shell"; target = "fish"; scopes = [ "terminal" ];
      word = "dp"; desc = "Run a command through hyprctl dispatch exec";
      action = "hyprctl dispatch exec"; }

    { kind = "word"; app = "Shell"; target = "fish"; scopes = [ "terminal" ];
      word = "ns"; desc = "Search nixpkgs with nix-search-tv";
      action = "nix-search-tv print | fzf --preview 'nix-search-tv preview {}' --scheme history"; }

    { kind = "word"; app = "Shell"; target = "fish"; scopes = [ "terminal" ];
      word = "ls"; desc = "ls -al";
      action = "ls -al"; }

    { kind = "word"; app = "Shell"; target = "fish"; scopes = [ "terminal" ];
      word = "fzf"; desc = "fzf with a bat preview";
      action = "fzf --preview 'bat --color=always {}'"; }

    { kind = "word"; app = "Shell"; target = "fish"; scopes = [ "terminal" ];
      word = "gi"; desc = "gh issue";
      action = "gh issue"; }

    { kind = "word"; app = "Shell"; target = "fish"; scopes = [ "terminal" ];
      word = "gil"; desc = "gh issue list";
      action = "gh issue list"; }

    { kind = "word"; app = "Shell"; target = "fish"; scopes = [ "terminal" ];
      word = "gin"; desc = "Create a gh issue with a title";
      action = ''gh issue create -b "" -t ''; }

    { kind = "word"; app = "Shell"; target = "fish"; scopes = [ "terminal" ];
      word = "gic"; desc = "Close a gh issue";
      action = "gh issue close "; }

    { kind = "word"; app = "Shell"; target = "fish"; scopes = [ "terminal" ];
      word = "gib"; desc = "Open the repository in the browser";
      action = "gh browse"; }
  ];
}
