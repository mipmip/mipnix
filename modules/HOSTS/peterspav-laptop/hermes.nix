{ inputs, ... }:
let
  meshIP = inputs.self.nebulaNodes.peterspav;
  dashboardPort = 9119;
  stateDir = "/var/lib/hermes";

  datasets = {
    # Hermes' memory, skills, sessions and the ChatGPT OAuth tokens it refreshes
    # itself. Live SQLite files are copied with .backup first, the same reason
    # the Grafana dataset on dapperehaan does.
    peterspav-hermes.paths = [ "/var/backups/restic/hermes" ];
    peterspav-hermes.keep = [
      "--keep-daily" "7" "--keep-weekly" "5"
      "--keep-monthly" "12" "--keep-yearly" "9999"
    ];
  };
in
{
  lobby.services.hermes = {
    title = "Hermes";
    description = "Always-on agent; talk to @hermes on Matrix";
    host = "peterspav";
    url = "http://${meshIP}:${toString dashboardPort}";
    access = "nebula";
    category = "tools";
  };

  flake.resticRepos.peterspav = builtins.attrNames datasets;

  flake.modules.nixos.peterspav = { config, pkgs, lib, ... }: {
    imports = [
      inputs.hermes-agent.nixosModules.default
      inputs.self.modules.nixos.backup-restic-piethein
    ];

    age.secrets = {
      hermes-env.file = ../../../secrets/hermes-env.age;
      hermes-matrix-password.file = ../../../secrets/hermes-matrix-password.age;
      hermes-dashboard-token = {
        file = ../../../secrets/hermes-dashboard-token.age;
        owner = config.services.hermes-agent.user;
      };
    };

    services.hermes-agent = {
      enable = true;
      inherit stateDir;

      settings = {
        model = {
          provider = "opencode-go";
          default = "glm-5.2";
        };
        providers.opencode-go = {
          base_url = "https://opencode.ai/zen/go/v1";
          key_env = "OPENCODE_GO_API_KEY";
          api_mode = "chat_completions";
          default_model = "glm-5.2";
        };
        image_gen.provider = "openai-codex";
        tts.provider = "edge";
      };

      environmentFiles = [
        config.age.secrets.hermes-env.path
        config.age.secrets.hermes-matrix-password.path
      ];

      environment = {
        MATRIX_HOMESERVER = "https://nuremberg.pimsnel.com";
        MATRIX_USER_ID = "@hermes:nuremberg.pimsnel.com";
        MATRIX_ALLOWED_USERS = "@pim:nuremberg.pimsnel.com";
      };

      backend = {
        mode = "dashboard";
        host = meshIP;
        port = dashboardPort;
        waitFor = "interface";
        interfaceName = "nebula.mesh";
        sessionTokenFile = config.age.secrets.hermes-dashboard-token.path;
      };
    };

    # peterspav is a server: it keeps running with the lid closed and never
    # suspends on idle, at the login screen or in pim's GNOME session.
    services.logind.settings.Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
      HandleLidSwitchDocked = "ignore";
      IdleAction = "ignore";
    };
    services.displayManager.gdm.autoSuspend = false;
    programs.dconf.profiles.user.databases = [
      {
        settings."org/gnome/settings-daemon/plugins/power" = {
          sleep-inactive-ac-type = "nothing";
          sleep-inactive-battery-type = "nothing";
        };
      }
    ];

    mipnix.backup.piethein = {
      enable = true;
      datasets = lib.mapAttrs (name: ds: ds // {
        prepareCommand = ''
          set -eu
          dst=/var/backups/restic/hermes
          rm -rf "$dst"
          install -d -m 0700 "$dst"
          cd ${stateDir}
          ${pkgs.findutils}/bin/find . -type d -exec install -d -m 0700 "$dst/{}" \;
          ${pkgs.findutils}/bin/find . -type f ! -name '*.db' ! -name '*.db-wal' ! -name '*.db-shm' \
            -exec cp -a {} "$dst/{}" \;
          ${pkgs.findutils}/bin/find . -type f -name '*.db' -print0 | while IFS= read -r -d "" db; do
            ${pkgs.sqlite}/bin/sqlite3 "$db" ".backup '$dst/$db'"
          done
        '';
        cleanupCommand = "rm -rf /var/backups/restic/hermes";
      }) datasets;
    };
  };
}
