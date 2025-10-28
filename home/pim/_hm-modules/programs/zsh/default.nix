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

            shellAliases = config.shared.shellAliases;
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


    ];


}

