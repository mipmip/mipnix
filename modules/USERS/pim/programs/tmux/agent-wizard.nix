{ inputs, ... }:
{
  flake.hotkeys = [

    { kind = "prefixed"; app = "tmux"; target = "tmux"; scopes = [ "terminal" ];
      group = "tools"; key = "V"; desc = "taw, coding agents";
      action = ''run-shell "taw ui open >/dev/null 2>&1 || tmux display-message 'taw: could not open the popup'"''; }

    { kind = "prefixed"; app = "tmux"; target = "tmux"; scopes = [ "terminal" ];
      group = "tools"; key = "J"; desc = "taw, jump to agent that needs you";
      action = ''run-shell "taw notification open-target >/dev/null 2>&1 || tmux display-message 'taw: no agent needs you'"''; }

  ];

  flake.modules.homeManager.pim-tmux = { pkgs, lib, ... }:
    let
      version = "0.1.7";

      taw = pkgs.stdenvNoCC.mkDerivation {
        pname = "taw";
        inherit version;
        src = pkgs.fetchurl {
          url = "https://github.com/27medkamal/tmux-agent-wizard/releases/download/v${version}/taw-x86_64-unknown-linux-musl.tar.gz";
          sha256 = "084dx1gzpiyxcxiwsrih5c9f4ynm76kx6a4yh41k96rx4vgrvhzc";
        };
        sourceRoot = ".";
        installPhase = ''
          install -Dm755 taw $out/bin/taw
        '';
      };

      tmux-agent-wizard = pkgs.tmuxPlugins.mkTmuxPlugin {
        pluginName = "tmux-agent-wizard";
        inherit version;
        rtpFilePath = "tmux-agent-wizard.tmux";
        src = pkgs.fetchFromGitHub {
          owner = "27medkamal";
          repo = "tmux-agent-wizard";
          rev = "v${version}";
          hash = "sha256-Fu4Jfw4fFOedK2uWwk2EBE8/TI4RY/jpXFUiRSqAcoI=";
        };
      };
      machines = [ "peterspav" "doornappel" "stinkie" ];

      ipOf = name:
        lib.last (lib.splitString " "
          (lib.findFirst (h: lib.hasPrefix "${name} " h)
            (throw "agent-wizard: ${name} is not a nebula host")
            inputs.self.lib.nebulaHosts));
    in
    {
      home.packages = [ taw ];

      xdg.configFile."tmux-agent-wizard/config.toml".text = ''
        [machines]
        ${lib.concatMapStringsSep "\n" (m: ''${m} = "pim@${ipOf m}"'') machines}
      '';

      programs.tmux.plugins = [
        {
          plugin = tmux-agent-wizard;
          extraConfig = ''
            set -g @agent-wizard-bin '${taw}/bin/taw'
            set -g @agent-wizard-auto-install off
            set -g @agent-wizard 'V'
            set -g @agent-wizard-notification-key 'J'
          '';
        }
      ];

      programs.tmux.extraConfig = lib.mkAfter ''
        set -ga status-right '#[default] #{@agent_wizard_status} '
      '';
    };
}
