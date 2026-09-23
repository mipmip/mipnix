{
inputs,
...
}:
{
  flake.modules.homeManager.pim-zsh = { config, pkgs, ... }: {

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

      # Scrub Ghostty's GTK app-wrapper variables out of the shell environment.
      # See the matching comment in ../fish/default.nix for the full reasoning.
      # This goes in .zshenv (envExtra) rather than .zshrc so it runs before any
      # profile/rc hook that might invoke a GLib program.
      envExtra = ''
        unset GST_PLUGIN_SYSTEM_PATH_1_0 GI_TYPELIB_PATH GDK_PIXBUF_MODULE_FILE

        if [[ -n "$GIO_EXTRA_MODULES" ]]; then
          _gio_kept=()
          for _gio_dir in ''${(s.:.)GIO_EXTRA_MODULES}; do
            [[ "$_gio_dir" == */gstreamer-1.0 ]] || _gio_kept+=("$_gio_dir")
          done
          if (( $#_gio_kept )); then
            export GIO_EXTRA_MODULES="''${(j.:.)_gio_kept}"
          else
            unset GIO_EXTRA_MODULES
          fi
          unset _gio_kept _gio_dir
        fi
      '';

      sessionVariables = {
        BROWSER = "firefox";
        COLORTERM = "truecolor";
        PATH= "''$HOME/.npm-packages/bin:$HOME/bin:''$PATH";
        NODE_PATH="''$HOME/.npm-packages/lib/node_modules";
      };

      #shellAliases = config.shared.shellAliases;
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

      #set -o allexport
      #source /tmp/openai-api-key
      #source /tmp/bedrockpim-api-keys-env
      #source /tmp/bedrock-keys-for-avante-env
      #set +o allexport

      export PATH=~/.npm-packages/bin:$PATH

      # rme (RUNME.sh launcher) completions. compinit is already run by oh-my-zsh,
      # so compdef is available here. `rme --completions` is evaluated at tab-time,
      # so suggestions reflect the current directory's RUNME.sh.
      _rme() { compadd $(rme --completions) }
      compdef _rme rme

      '';
    };
  };
}
